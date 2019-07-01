local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local function ggz_layoutbox(s)
   local ret = wibox.widget({
      {
         {
            wibox.container.place(awful.widget.layoutbox(s)),
            {
               widget = wibox.widget.textbox,
               font = "Segoe UI bold 11",
               markup = '<span color=\'' .. beautiful.white .. '\'>Layout</span>',
               align = 'center',
            },
            widget = wibox.layout.flex.vertical,
         },
         widget = wibox.container.margin,
         left = dpi(2),
         bottom = dpi(8),
         right = dpi(2),
         top = dpi(8),
      },
      border_width = beautiful.taglist_shape_border_width,
      border_color = beautiful.taglist_shape_border_color,
      forced_width = beautiful.wibar_height,
      forced_height = beautiful.wibar_height,
      shape = beautiful.common_shape(dpi(16)),
      bg = beautiful.taglist_bg_empty,
      widget = wibox.container.background
   })

   ret:buttons(gears.table.join(
      awful.button({}, 1, function () awful.layout.inc( 1) end),
      awful.button({}, 3, function () awful.layout.inc(-1) end),
      awful.button({}, 4, function () awful.layout.inc( 1) end),
      awful.button({}, 5, function () awful.layout.inc(-1) end))
   ) -- layout box buttons
   return ret
end

return ggz_layoutbox
