local wibox = require("wibox")
local beautiful = require("beautiful")
local audio = require("api.audio")
local brightness = require("api.brightness")
local gears = require("gears")
local naughty = require("naughty")
local awful = require("awful")

local WIBOX_TIMEOUT = 4

for s in screen do
	s.mediapopup_widget_text = wibox.widget({
		widget = wibox.widget.textbox,
		align = 'center',
		text = "Volume"
	})

	s.mediapopup_widget_firstrun = true

	s.mediapopup_widget = wibox.widget({
		s.mediapopup_widget_text,
		layout = wibox.layout.flex.horizontal,
		forced_width = dpi(256),
		forced_height = dpi(64),
	})

	s.mediapopup_wibox = awful.popup({
		placement = awful.placement.top,
		shape = beautiful.common_shape(dpi(16)),
		border_width = beautiful.border_width,
		border_color = beautiful.blue,
		screen = s,
		visible = false,
		ontop = true,
		widget = s.mediapopup_widget
	})

	s.mediapopup_timer = gears.timer({
		timeout = WIBOX_TIMEOUT,
		callback = function() s.mediapopup_wibox.visible = false end
	})

	s.mediapopup_wibox_trigger = function()
		if s.mediapopup_widget_firstrun then
			s.mediapopup_widget_firstrun = false
		else
			s.mediapopup_wibox.visible = true
		end
	end

	s.mediapopup_widget:connect_signal(audio.signal.mic_update, function(_, status)
		local statustext = "Microphone: " .. status.mic_level .. "%"
		if status.mic_muted then statustext = "Microphone muted" end
		s.mediapopup_widget_text.text = statustext
		s.mediapopup_timer:again()
		s.mediapopup_wibox_trigger()
	end)

	s.mediapopup_widget:connect_signal(audio.signal.vol_update, function(_, status)
		local statustext = "Volume: " .. status.vol_level .. "%"
		if status.vol_muted then statustext = "Volume muted" end
		s.mediapopup_widget_text.text = statustext
		s.mediapopup_timer:again()
		s.mediapopup_wibox_trigger()
	end)

	s.mediapopup_widget:connect_signal(brightness.signal.update, function(_, level)
		s.mediapopup_widget_text.text = "Brightness: " .. level .. "%"
		s.mediapopup_timer:again()
		s.mediapopup_wibox_trigger()
	end)

	audio.attach(s.mediapopup_widget)
	brightness.attach(s.mediapopup_widget)
end
