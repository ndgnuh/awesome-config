local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local oldfont = beautiful.font
beautiful.font = beautiful.fonts.bold .. 9
local widget_volume = require("ggz.widgets.volume")
local widget_battery = require("ggz.widgets.battery")

local infobox = wibox.widget({
   forced_width = dpi(256)*1.3,
   forced_height = beautiful.wibar_height - dpi(4),
   widget = wibox.container.background,
   shape = function(cr, w, h)
      local r = dpi(16)
      local mr = r/2.5
      local lr = h/2
      cr:arc(lr, lr, lr, math.pi, 3*math.pi/2)
      cr:arc(w-mr, mr, mr, 3*math.pi/2, 0)
      cr:arc(w-r, h-r, r, math.pi*2 , math.pi/2)
      cr:arc(lr, h-lr, lr, math.pi/2, math.pi)
      cr:line_to(0, r)
      cr:close_path()
   end,
   border_color = beautiful.blue,
   border_width = beautiful.wibar_border_width,
   bg = beautiful.shade,
   wibox.container.margin(wibox.widget{
      {
         layout = wibox.layout.align.horizontal,
         wibox.widget.textbox(beautiful.whitetext("Lv. " .. iglevel)),
         wibox.container.place(wibox.widget.textbox(beautiful.whitetext(ign)))
      },
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.widget.textbox(beautiful.whitetext("BAT")),
         widget_battery,
      },
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.widget.imagebox(gears.color.recolor_image(beautiful.icon_dir .. "time.png", beautiful.yellow)),
         wibox.widget.textclock(beautiful.whitetext("%H:%M %d/%m/%Y")),
         wibox.widget.imagebox(gears.color.recolor_image(beautiful.icon_dir .. "media.png", beautiful.blue)),
         widget_volume,
         spacing = dpi(8)
      },
      layout = wibox.layout.flex.vertical
   }, beautiful.wibar_height + dpi(8), dpi(4), dpi(4), dpi(4))
})

local avatar_image = wibox.widget({
   forced_width = beautiful.wibar_height,
   forced_height = beautiful.wibar_height,
   widget = wibox.container.radialprogressbar,
   color = beautiful.orange,
   border_color = beautiful.orange,
   border_width = dpi(4),
   padding = dpi(4),
   {
      widget = wibox.widget.imagebox,
      image = beautiful.icon_dir .. "hakase.png",
   },
})


for s in screen do
   s.info = wibox.widget({
      forced_width = dpi(256)*1.3 + dpi(12), -- percise width of the widget
      forced_height = beautiful.wibar_height,
      layout = wibox.layout.manual
   })
   s.info:add_at(infobox, {
      x = dpi(12),
      y = dpi(4)
   })
   s.info:add_at(avatar_image, {
      x = dpi(2),
      y = 0
   })
end

-- revert to default font
beautiful.font = oldfont
