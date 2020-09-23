local wibox = require("wibox")
local shape = require("gears.shape")
local beautiful = require("beautiful")

local di = wibox.widget({
   widget = wibox.container.background,
   bg = beautiful.white,
   forced_width = 64,
   forced_height = 64,
   shape = shape.circle,
   wibox.container.place(
      wibox.widget.textbox("<span color='".. beautiful.blue .. "'>?</span>")
   )
})

local w = 64
return wibox.widget.draw_to_image_surface(di, w, w)
