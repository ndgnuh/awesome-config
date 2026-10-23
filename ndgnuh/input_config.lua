local awful = require("awful")

if awful.input then
	-- Touchpad settings
	awful.input.tap_to_click = 1
	awful.input.natural_scrolling = 0
	awful.input.accel_speed = 0.3

	-- Keyboard settings
	awful.input.xkb_layout = "us"
	awful.input.xkb_options = ""
	awful.input.keyboard_repeat_rate = 30
	awful.input.keyboard_repeat_delay = 300
end
