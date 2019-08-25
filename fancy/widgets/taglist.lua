local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local button_taglist = gears.table.join(
   awful.button({}, 1, function(t)
      t:view_only()
      for _, tag in ipairs(awful.screen.focused().tags) do
         if tag.selected then
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
         else
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
         end
      end
   end),
   awful.button({}, 3, awful.tag.viewtoggle)
)

for s in screen do
   s.taglist = awful.widget.taglist({
      filter = awful.widget.taglist.filter.all,
      layout = {
         layout = wibox.layout.fixed.vertical
      },
      widget_template = {
         widget = wibox.container.background,
         id = "background_role",
         forced_height = beautiful.wibar_height,
         {
            widget = wibox.container.margin,
            margins = dpi(2),
            id = "text_margin_role",
            {
               widget = wibox.widget.textbox,
               align = "center",
               id = "text_role"
            }
         }
      },
      screen = s,
      buttons = button_taglist
   })
end
