local wibox = require("wibox")
local beautiful = require("beautiful")
local audio = require("api.audio")
local gears = require("gears")
local naughty = require("naughty")

local WIBOX_TIMEOUT = 2

for s in screen do
	s.mediapopup_widget_text = wibox.widget({
		widget = wibox.widget.textbox,
		align = 'center',
		text = "Volume"
	})

	s.mediapopup_widget_firstrun = true

	s.mediapopup_widget = wibox.widget({
		{
			s.mediapopup_widget_text,
			widget = wibox.container.place
		},
		layout = wibox.layout.fixed.horizontal
	})

	s.mediapopup_wibox = wibox({
		x = s.geometry.x + s.geometry.width/2 - dpi(128),
		y = s.geometry.y + s.geometry.height/2 - dpi(32),
		width = dpi(256),
		height = dpi(64),
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

	audio.attach(s.mediapopup_widget)
end
