local re = require
local wibox = re"wibox"
local beautiful = re"beautiful"
local awful = re"awful"
local gears = re"gears"
local sh = re"sh"

local acpi_matcher = "([a-zA-Z0-9 ]+): ?(%a+), (%d+)%%, ([0-9:]+) remaining"
local timeout = 5

local b_widget = wibox.widget{
	widget = wibox.container.margin,
	left = 8,
	right = 8,
	{
		widget = wibox.container.arcchart,
		min_value = 0,
		max_value = 100,
		value = 40,
		id = 'arcbattery_role',
		colors = {beautiful.color4},
		{
			widget = wibox.container.place,
			{
				widget = wibox.widget.textbox,
				id = 'battery_role',
				font = 'monospace 8',
				markup = "."
			}
		}
	},
}


local update = function()
	local acpi_handle = function(stdo, stde)
		local bname, bstatus, bpercent, btimeleft = stdo:match(acpi_matcher)
		b_widget:get_children_by_id('battery_role')[1].markup = bpercent:sub(1, 1)
		bpercent = tonumber(bpercent)
		b_widget:get_children_by_id('arcbattery_role')[1].value = bpercent
	end
	awful.spawn.easy_async_with_shell("acpi", acpi_handle)
end

update()

gears.timer{
	timeout = timeout,
	callback = update,
}:start()


return b_widget
