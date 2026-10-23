---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/Bus.html
---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/Engine.html
---@see https://lazka.github.io/pgi-docs/IBus-1.0/classes/EngineDesc.html
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local lgi = require("lgi")
local IBus = lgi.require("IBus")
local state = require("state")
local ic = require("lib.icecream")

if state.first_run then
end

ic(state.first_run)

local m = gears.object()

function m:init()
	--- Already initialized
	if self.bus then
		return
	end

	IBus.init()
	local bus = IBus.Bus()
	self.bus = bus

	bus.on_connected = function(this)
		naughty.notification({
			title = "IBus",
			message = "IBus connected",
		})
		this:set_watch_dbus_signal(true)
		this:set_watch_ibus_signal(true)
		local engine = this:get_global_engine()
		self:emit_signal("ibus:global-engine-changed", engine.name)
	end

	bus.on_global_engine_changed = function(_, engine_name)
		self:emit_signal("ibus:global-engine-changed", engine_name)
	end
end

function m:set_engine(engine_name)
	m:init()
	if self.bus:is_connected() then
		self.bus:set_global_engine(engine_name)
	else
		awful.spawn("ibus engine " .. engine_name)
		self:emit_signal("ibus:global-engine-changed", engine_name)
	end
end

return m
