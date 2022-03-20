local lgi = require("lgi")
local IBus = lgi.IBus

local bus = IBus.Bus.new()
dump(bus:get_global_engine().name)
dump(bus:is_connected())
function bus.on_global_engine_changed(self, ...)
	dump(123)
	dump({ ... })
end

function bus.on_connected(self, ...)
	dump("hello")
end

function bus.on_disconnected(self, ...)
	dump("hello")
end
