local awful = re"awful"
local wibox = re"wibox"
local gears = re"gears"

return {
	{
		widget = wibox.layout.fixed.horizontal,
		spacing = 4,
		{
			forced_width = 2,
			shape = gears.shape.circle,
			widget = wibox.widget.separator
		},
		{
			forced_width = 2,
			shape = gears.shape.circle,
			widget = wibox.widget.separator
		},
		{
			forced_width = 2,
			shape = gears.shape.circle,
			widget = wibox.widget.separator
		},
		forced_height = 4,
	},
	valign = 'center',
	halign = 'center',
	widget = wibox.container.place,
}
