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
   s.mytaglist = awful.widget.taglist({
      screen  = s,
      filter  = awful.widget.taglist.filter.all,
      buttons = button_taglist,
      widget_template = {
         {
            {
               {
                  widget = wibox.container.place,
                  {
                     widget = wibox.widget.imagebox,
                     resize = true,
                     id = 'icon_role',
                  },
               },
               {
                  widget = wibox.widget.textbox,
                  id = 'text_role',
                  align = 'center'
               },
            layout = wibox.layout.flex.vertical,
            },
            widget = wibox.container.margin,
            left = beautiful.taglist_shape_border_width,
            right = beautiful.taglist_shape_border_width,
            top = dpi(8),
            bottom = dpi(8),
         },
         forced_width = beautiful.wibar_height,
         forced_height = beautiful.wibar_height,
         id = 'background_role',
         widget = wibox.container.background,
         -- update_callback = function(self, c3, index, objects) --luacheck: no unused args
         --    self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
         -- end,
      }
   })

end
