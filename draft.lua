local wibox = require("wibox")
local beautiful = require("beautiful")
local pill = require("widgets.pill_container")
local awful = require("awful")

p = awful.popup {
	x = 0,
	y = 0,
	ontop = true,
	visible = true,
	placement = awful.placement.top_left,
	widget = {
		widget = pill,
		wibox.widget.textbox("HELLO WORLD")
	}
}

-- ic(p.widget)

