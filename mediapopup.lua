local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local media = require("mediakeys")
local naughty = require("naughty")

local popup = {}

popup.text = wibox.widget({widget = wibox.widget.textbox, valign = "center", text = "media popup"})
popup.icon = wibox.widget({widget = wibox.widget.imagebox})
popup.icons = {}
popup.icons.volume = ""
popup.icons.brightness = ""
popup.layout = wibox.widget({
	{
		layout = wibox.layout.fixed.horizontal,
		forced_width = dpi(256),
		forced_height = dpi(32),
		border_width = dpi(4),
		popup.icon,
		popup.text
	},
	widget = wibox.container.margin,
	margins = dpi(16)
})
popup.wibox = awful.popup({
	placement = 'top',
	ontop = true,
	visible = false,
	widget = popup.layout
})

local timer = gears.timer({
	timeout = 5,
	callback = function() popup.wibox.visible = false end
})

local triggerwibox = function()
	popup.wibox.visible = true
	timer:again()
end

awesome.connect_signal(media.signal.audio, function()
	awful.spawn.easy_async(media.cmd.vol_get, function(o)
		-- Sample output
		-- Mono: Playback 63 [50%] [-32.00dB] [on]
		lv, stat = string.match(o, ".*%[(%d%d?%d?)%%%].*%[(%a*)].*")
		if stat == "on" then
			popup.text.markup = "Volume " .. lv .. "%"
		else
			popup.text.markup = "Volume muted"
		end
		triggerwibox()
	end)
end)

awesome.connect_signal(media.signal.light, function()
	awful.spawn.easy_async(media.cmd.brn_get, function(o)
		-- Sample output: 43.33
		naughty.notify({ text = "stdout" .. tostring(o) })
		o = string.match(o, "(%d%d?%d?).*")
		naughty.notify({ text = o })
		popup.text:set_markup_sliently("Brightness " .. tostring(o) .. "%")
		-- triggerwibox()
	end)
end)
