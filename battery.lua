local re = require
local lgi = require"lgi"
local wibox = re"wibox"
local beautiful = re"beautiful"
local awful = re"awful"
local gears = re"gears"
local sh = re"sh"
local icon = re"icon"

local upower = re"upower"

local w = wibox.widget{
	widget = wibox.container.margin,
	margins = 8,
	{
		widget = wibox.widget.textbox,
		halign = 'center',
		valign = 'center',
		forced_width = beautiful.wibar_width,
		id = 'battery',
		font = 'sans 11',
		markup = '',
	}
}

local update_function = function(battery)
	local txt = w:get_children_by_id('battery')[1]
	local percentage = math.floor(battery.percentage)
	if battery.state == "discharging" then
		txt.markup = string.format("<u>%s</u>", percentage)
	else
		txt.markup = string.format("<b>%s</b>", percentage)
	end
end

update_function(upower.battery)

upower.watch(update_function)
return w
