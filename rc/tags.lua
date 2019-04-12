local config = require("config")
local awful = require("awful")

awful.screen.connect_for_each_screen(function(s)
	awful.tag(config.tags, s, awful.layout.layouts[1])
end)

return true