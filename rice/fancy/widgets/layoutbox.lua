local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

for s in screen do
   s.layoutbox = awful.widget.layoutbox{
      forced_width = beautiful.wibar_height,
   }
end
