local awful = require("awful")
local gears = require("gears")

awful.add_key_binding = function(...)
	root.keys(gears.table.join(root.keys(), ...))
end
