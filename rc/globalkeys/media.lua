local awful = require("awful")
local gtable = require("gears.table")

local keyconf = {
}

for _, key in pairs(keyconf) do
	root.keys(gtable.join(
		root.keys(),
		awful.key({}, key.key, function()
			awful.spawn.easy_async_with_shell(key.cmd, function(o)
			end)
		end)
	))
end


return true
