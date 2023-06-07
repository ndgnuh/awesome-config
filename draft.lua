local wibox = require("wibox")
local beautiful = require("beautiful")
local pill = require("widgets.pill_container")
local awful = require("awful")

p = wibox {
	x = 1920-200,
	y = 1080-200,
	width = 200,
	height = 200,
	ontop = true,
	visible = true,
	bg = "#ffffff",
	widget = wibox.widget{
		widget = wibox.layout.fixed.vertical,
		{
			widget = pill,
			spacing = 10,
			bg = "#FF0000",
			margins = 10,
			{
				widget = wibox.layout.fixed.horizontal,
				{
					widget = wibox.widget.textbox,
					text = "abc"
				},
				{
					widget = wibox.widget.textbox,
					text = "Hello world 1"
				}
			}
		},
		{
			margins = 10,
			widget = pill,
			bg = "#0000FF",
			wibox.widget.textbox("Hello world 2")
		}
	}
}
