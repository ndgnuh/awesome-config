local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local capi = {
	screen = screen,
	awesome = awesome,
	client = client
}
local common = require("awful.widget.common")
--
-- local test = awful.popup{
-- 	placement = "top_right",
-- 	visible = true,
-- 	ontop = true,
-- 	widget = wibox.widget{
-- 		forced_width = 50,
-- 		forced_height = 50,
-- 		widget = wibox.container.background,
-- 		bg = "#ffff00"
-- 	}
-- }
local fps = 30

local colors = {
	"#ff0000",
	"#ee0000",
	"#dd0000",
	"#cc0000",
	"#bb0000",
	"#aa0000"
}

local i = 1
gears.timer{
	timeout = 1,
	callback = function()
		-- test.widget.bg = colors[(i-1)%#colors + 1]
		-- local c =  colors[(i-1)%#colors + 1]
		naughty.notify{ text = "abcd" }
	end,
	single_shot = false,
}
naughty.notify{ text = "abc" }
