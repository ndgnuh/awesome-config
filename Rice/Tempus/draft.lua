local re = require
local common =require"awful.widget.common"
local awful =require"awful"
local wibox =require"wibox"

local wb = wibox{
	x = 100, y = 100,
	width = 32, height = 132,
	widget = wibox.layout.fixed.vertical(),
	visible = true,
	ontop = true,
}

local label = function(x)
	-- return text, bg_color, bg_image, not taglist_disable_icon and icon or nil, other_args
	return x, "#ff0000", nil, nil, nil
end

common.list_update(wb.widget, {}, label, {}, {1, 2, 3})
