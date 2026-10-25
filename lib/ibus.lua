---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/Bus.html
---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/Engine.html
---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/EngineDesc.html
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local lgi = require("lgi")
local IBus = lgi.require("IBus")
local GLib = lgi.GLib
local Gio = lgi.Gio

local m = gears.object()

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

--- Find the address of a running ibus-daemon from ~/.config/ibus/bus.
--- The compositor's own env (WAYLAND_DISPLAY/DISPLAY) may not match the
--- display ibus-daemon was started with, so fall back to scanning all files.
local function find_ibus_address()
	local address, pid = read_bus_file(IBus.get_socket_path())
	if address and is_alive(pid) then
		return address
	end

	local dir = GLib.build_filenamev({ GLib.get_user_config_dir(), "ibus", "bus" })
	local enum = Gio.File.new_for_path(dir):enumerate_children("standard::name", 0)
	if not enum then
		return nil
	end
	for info in
		function()
			return enum:next_file()
		end
	do
		address, pid = read_bus_file(dir .. "/" .. info:get_name())
		if address and is_alive(pid) then
			enum:close()
			return address
		end
	end
	enum:close()
	return nil
end

function m:init()
	--- Already initialized
	if self.bus then
		return
	end

	IBus.init()
	local address = os.getenv("IBUS_ADDRESS") or find_ibus_address()
	naughty.notification({
		title = "IBus address",
		message = address,
	})
	if not address then
		naughty.notification({
			title = "IBus",
			message = "No running ibus-daemon found",
		})
		return
	end

	--- IBus.Bus() reads the address from IBUS_ADDRESS, unset it afterward
	--- so spawned clients don't inherit a stale address
	local had_env = os.getenv("IBUS_ADDRESS") ~= nil
	GLib.setenv("IBUS_ADDRESS", address, true)
	local bus = IBus.Bus.new_async_client()
	if not had_env then
		GLib.unsetenv("IBUS_ADDRESS")
	end
	self.bus = bus

	local function on_connected(this)
		naughty.notification({
			title = "IBus",
			message = "IBus connected",
		})
		this:set_watch_dbus_signal(true)
		this:set_watch_ibus_signal(true)
		local engine = this:get_global_engine()
		self:emit_signal("ibus:global-engine-changed", engine.name)
	end
	bus.on_connected = on_connected

	bus.on_global_engine_changed = function(_, engine_name)
		self:emit_signal("ibus:global-engine-changed", engine_name)
	end

	--- IBus.Bus() connects synchronously in its constructor, so the
	--- "connected" signal has already fired before the handler was attached
	if bus:is_connected() then
		on_connected(bus)
	end
end

function m:set_engine(engine_name)
	m:init()
	if self.bus and self.bus:is_connected() then
		self.bus:set_global_engine(engine_name)
	else
		awful.spawn("ibus engine " .. engine_name)
		self:emit_signal("ibus:global-engine-changed", engine_name)
	end
end

return m
