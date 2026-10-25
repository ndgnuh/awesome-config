---Provider for the name of the current global IBus engine (e.g. "xkb:us::eng").
---The state is nil until ibus-daemon reports an engine.
local overdrip = require("lib.overdrip")
local ibus = require("lib.ibus")

local m = {}

m.global_ibus_engine_provider = overdrip.provider(function()
	return ibus:current_global_engine()
end)

ibus:connect_signal("ibus:global-engine-changed", function(_, engine_name)
	if m.global_ibus_engine_provider.state ~= engine_name then
		m.global_ibus_engine_provider.state = engine_name
	end
end)

ibus:init()

return m
