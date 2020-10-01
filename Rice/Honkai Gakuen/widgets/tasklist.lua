local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

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
   s.mytasklist = awful.widget.tasklist({
      screen  = s,
      filter  = awful.widget.tasklist.filter.focused,
      buttons = button_tasklist,
      widget_template = {
         {
            {
               widget = wibox.widget.imagebox,
               id = 'icon_role'
            },
            {
               align = 'center',
               widget = wibox.widget.textbox,
               id = 'text_role',
            },
            layout = wibox.layout.align.horizontal
         },
         widget = wibox.container.background,
         id = 'background_role'
      }
   })
end
