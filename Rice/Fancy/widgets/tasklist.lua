local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button_tasklist = gears.table.join(
   awful.button({}, 1, function (c)
      if c == client.focus then
         c.minimized = true
      else
         c:emit_signal("request::activate", "tasklist", {raise = true})
      end
   end),
   awful.button({}, 3, function()
      awful.menu.client_list({ theme = { width = 250 } })
   end),
   awful.button({}, 4, function ()
      awful.client.focus.byidx(1)
   end),
   awful.button({}, 5, function ()
      awful.client.focus.byidx(-1)
   end)
)

-- Create a tasklist widget
for s in screen do
   s.tasklist = awful.widget.tasklist{
      screen  = s,
      filter  = awful.widget.tasklist.filter.currenttags,
      buttons = button_tasklist,
      layout = {
         layout = wibox.layout.fixed.horizontal,
         -- spacing = -beautiful.wibar_height,
      },
      widget_template = {
         {
            widget = wibox.container.place,
            {
               widget = wibox.container.margin,
               left = dpi(8),
               right = dpi(8),
               {
                  widget = wibox.widget.textbox,
                  align = 'center',
                  halign = 'center',
                  id = 'text_role',
               },
            }
         },
         forced_width = (s.geometry.width - beautiful.wibar_height)/5,
         widget = wibox.container.background,
         id = 'background_role'
      }
   } 
end
