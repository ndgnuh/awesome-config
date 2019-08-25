local beautiful = require("beautiful")
local gears = require("gears")

local theme = {}

theme.hexagon = function(cr, w, h)
   cr:move_to(h/3, 0)
   cr:line_to(0, h/2)
   cr:line_to(h/3, h)
   cr:line_to(w - h/3, h)
   cr:line_to(w, h/2)
   cr:line_to(w - h/3, 0)
   cr:close_path()
end

beautiful.taglist_bg_focus = beautiful.wibar_bg
beautiful.taglist_bg_empty = beautiful.wibar_bg
beautiful.taglist_bg_occupied = beautiful.wibar_bg
beautiful.taglist_spacing = 4
beautiful.taglist_shape = theme.hexagon
beautiful.taglist_shape_border_width = 4
beautiful.taglist_shape_border_color =  "#01cdfe"
beautiful.taglist_shape_border_color_focus = "#b967ff"
beautiful.taglist_shape_border_color_empty = "#fffb96"
beautiful.taglist_fg_occupied = beautiful.taglist_shape_border_color
beautiful.taglist_fg_focus = beautiful.taglist_shape_border_color_focus
beautiful.taglist_fg_empty = beautiful.taglist_shape_border_color_empty

beautiful.wibar_height = 48
beautiful.wibar_border_width = 8

beautiful.useless_gap = 8
