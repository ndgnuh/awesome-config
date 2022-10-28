local wibox = require("wibox")
local shadow_color = "#111"
local shadow_width = 2

local function shadow(geo)
	return {
		widget = wibox.container.background,
		forced_width = geo.width,
		forced_height = geo.height,
		wibox.widget.textbox(""),
		bg = shadow_color,
	}
end

local function fake_shadow(args)
	local widget = args.widget
	widget.forced_width = args.width - args.right
	widget.forced_width = args.width - args.right
	local container = wibox.widget({
		widget = wibox.layout.fixed.horizontal,
		{
			widget = wibox.layout.fixed.vertical,
			widget,
			shadow({ width = args.bottom }),
		},
		shadow({ width = args.right }),
	})

	return container
end

return fake_shadow
