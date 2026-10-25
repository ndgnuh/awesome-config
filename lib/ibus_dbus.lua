--- IBus client talking to ibus-daemon's private D-Bus directly.
---
--- Unlike `lib.ibus`, this does not use `lgi.IBus.Bus`, which is a process-wide
--- singleton that connects once, caches the bus file path and never recovers
--- if that first connect fails (e.g. ibus-daemon starts after the compositor).
---
--- Here the address is read from ~/.config/ibus/bus, the connection is owned by
--- this module and it reconnects whenever that directory changes or the
--- connection drops.
---
--- Usage:
---   local ibus = require("lib.ibus_dbus")
---   ibus:init() -- safe to call before ibus-daemon is running
---   ibus:connect_signal("ibus:global-engine-changed", function(_, engine_name)
---       print("engine: " .. engine_name)
---   end)
---   ibus:set_engine("Bamboo")
---   ibus:is_connected() -- true once connected to ibus-daemon
---   ibus:current_global_engine() -- e.g. "xkb:us::eng", nil until known
---
--- Signals:
---   ibus:connected
---   ibus:disconnected
---   ibus:global-engine-changed (engine_name)
---@see https://github.com/ibus/ibus/blob/main/bus/ibusimpl.c
local awful = require("awful")
local gears = require("gears")
local lgi = require("lgi")
local GLib = lgi.GLib
local Gio = lgi.Gio

local IBUS_SERVICE = "org.freedesktop.IBus"
local IBUS_PATH = "/org/freedesktop/IBus"
local IBUS_INTERFACE = "org.freedesktop.IBus"
local CALL_TIMEOUT = 2000

local bus_dir = GLib.build_filenamev({ GLib.get_user_config_dir(), "ibus", "bus" })

---@class IBusDBus: gears.object
---@field conn? any Gio.DBusConnection
---@field address? string
---@field engine? string
local m = gears.object()

--- Keep track of the engine for `current_global_engine`
m:connect_signal("ibus:global-engine-changed", function(self, engine_name)
	self.engine = engine_name
end)

--- Parse an ibus bus file, returns address and daemon pid
local function read_bus_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local address, pid
	for line in f:lines() do
		address = address or line:match("^IBUS_ADDRESS=(.+)$")
		pid = pid or tonumber(line:match("^IBUS_DAEMON_PID=(%d+)$"))
	end
	f:close()
	return address, pid
end

local function is_alive(pid)
	return pid and gears.filesystem.dir_readable("/proc/" .. pid)
end

--- Address of a running ibus-daemon. The bus file name depends on the display
--- the daemon was started with, which may not match ours (e.g. a systemd
--- started daemon writes `-unix-0`), so take the most recently written file
--- whose daemon is still alive.
local function find_address()
	local env = os.getenv("IBUS_ADDRESS")
	if env then
		return env
	end

	local enum = Gio.File.new_for_path(bus_dir):enumerate_children("standard::name,time::modified", 0)
	if not enum then
		return nil
	end
	local best, best_mtime
	for info in function() return enum:next_file() end do
		local address, pid = read_bus_file(bus_dir .. "/" .. info:get_name())
		local mtime = info:get_attribute_uint64("time::modified")
		if address and is_alive(pid) and (not best_mtime or mtime > best_mtime) then
			best, best_mtime = address, mtime
		end
	end
	enum:close()
	return best
end

--- Engine name from a serialized IBusEngineDesc:
--- ('IBusEngineDesc', a{sv}, name, longname, ...), possibly boxed in variants
local function engine_desc_name(desc)
	while desc:get_type_string() == "v" do
		desc = desc:get_variant()
	end
	return desc:get_child_value(2):get_string()
end

function m:_drop_connection()
	local conn = self.conn
	if not conn then
		return
	end
	self.conn = nil
	self.address = nil
	if not conn:is_closed() then
		conn:close()
	end
	self:emit_signal("ibus:disconnected")
end

function m:_on_connected(conn, address)
	self.conn = conn
	self.address = address

	conn.on_closed = function(c)
		if self.conn == c then
			self:_drop_connection()
			self:reconnect()
		end
	end

	conn:signal_subscribe(
		IBUS_SERVICE,
		IBUS_INTERFACE,
		"GlobalEngineChanged",
		IBUS_PATH,
		nil,
		Gio.DBusSignalFlags.NONE,
		function(_, _, _, _, _, params)
			self:emit_signal("ibus:global-engine-changed", params:get_child_value(0):get_string())
		end
	)

	self:emit_signal("ibus:connected")

	--- Report the current engine
	conn:call(
		IBUS_SERVICE,
		IBUS_PATH,
		"org.freedesktop.DBus.Properties",
		"Get",
		GLib.Variant("(ss)", { IBUS_INTERFACE, "GlobalEngine" }),
		GLib.VariantType("(v)"),
		Gio.DBusCallFlags.NONE,
		CALL_TIMEOUT,
		nil,
		function(c, res)
			local result = c:call_finish(res)
			if result and self.conn == c then
				local desc = result:get_child_value(0):get_variant()
				self:emit_signal("ibus:global-engine-changed", engine_desc_name(desc))
			end
		end
	)
end

--- (Re)connect to the current ibus-daemon, if it changed or we are not connected
function m:reconnect()
	local address = find_address()
	if not address or (self.conn and address == self.address) then
		return
	end
	self:_drop_connection()

	--- Ignore results of older attempts that finish after a newer one started
	self.attempt = (self.attempt or 0) + 1
	local attempt = self.attempt
	Gio.DBusConnection.new_for_address(
		address,
		Gio.DBusConnectionFlags{ "AUTHENTICATION_CLIENT", "MESSAGE_BUS_CONNECTION" },
		nil,
		nil,
		function(_, res)
			local conn = Gio.DBusConnection.new_for_address_finish(res)
			if not conn then
				return
			end
			if attempt ~= self.attempt or self.conn then
				conn:close()
				return
			end
			self:_on_connected(conn, address)
		end
	)
end

function m:init()
	--- Already initialized
	if self.monitor then
		return
	end

	GLib.mkdir_with_parents(bus_dir, tonumber("700", 8))
	self.monitor = Gio.File.new_for_path(bus_dir):monitor_directory(Gio.FileMonitorFlags.NONE)
	--- ibus-daemon writes the bus file in several steps, coalesce the events
	self.monitor.on_changed = function()
		if not self.reconnect_timer then
			self.reconnect_timer = gears.timer.start_new(0.5, function()
				self.reconnect_timer = nil
				self:reconnect()
				return false
			end)
		end
	end

	self:reconnect()
end

function m:is_connected()
	return self.conn ~= nil and not self.conn:is_closed()
end

--- Name of the current global engine, as last reported by ibus-daemon (or set
--- by `set_engine` while disconnected). Does not block on D-Bus.
---@return string|nil
function m:current_global_engine()
	return self.engine
end

function m:set_engine(engine_name)
	self:init()
	if self:is_connected() then
		self.conn:call(
			IBUS_SERVICE,
			IBUS_PATH,
			IBUS_INTERFACE,
			"SetGlobalEngine",
			GLib.Variant("(s)", { engine_name }),
			nil,
			Gio.DBusCallFlags.NONE,
			CALL_TIMEOUT,
			nil,
			function(c, res)
				c:call_finish(res)
			end
		)
	else
		awful.spawn({ "ibus", "engine", engine_name })
		self:emit_signal("ibus:global-engine-changed", engine_name)
	end
end

return m
