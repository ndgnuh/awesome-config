local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local client_info = require.rel("client_info")

local spawn_or_cycle = require("lib.spawn_or_cycle")
-- local ibus = require("lib.ibus")
-- local ibus = require("lib.ibus-spawn")
local ic = require("lib.icecream")

local BatteryIcon = require("ndgnuh.widgets.BatteryIcon")
local IbusIcon = require("ndgnuh.ibus-spawn")

local text_clock_command = spawn_or_cycle({
	command = "gnome-calendar",
	pattern = "org.gnome.Calendar",
})
local text_clock = wibox.widget.textclock()
text_clock:connect_signal("button::press", function()
	text_clock_command:run()
end)

local wibar = function(s)
	-- default gutter
	local gutter = beautiful.gutter or 8

	return awful.wibar({
		position = "top",
		screen = s,
		widget = {
			widget = wibox.container.margin,
			margins = {
				top = gutter / 2,
				bottom = gutter / 2,
				left = gutter,
				right = gutter,
			},
			{
				layout = wibox.layout.flex.horizontal,
				{
					widget = wibox.layout.fixed.horizontal,
					spacing = beautiful.gutter,
					client_info.ClientIcon,
					client_info.ClientTitle,
				},
				nil,
				{ -- Right widgets
					widget = wibox.container.place,
					halign = "right",
					{
						layout = wibox.layout.fixed.horizontal,
						expand = "none",
						spacing = beautiful.gutter,
						-- Lags in SomeWM, dunno why...
						wibox.widget.systray(),
						IbusIcon,
						BatteryIcon,
						text_clock,
					},
				},
			},
		},
	})
end

return wibar
