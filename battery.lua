-- requires{{{
local upower = require"upower"
local wibox = require"wibox"
local gears = require"gears"
local icon = require"icon"
local beautiful = require"beautiful"--}}}

-- math lib{{{
local floor = math.floor
local ceil = math.ceil--}}}

local batteryicons = {--{{{
  icon"mdi/battery-10.svg",
  icon"mdi/battery-20.svg",
  icon"mdi/battery-30.svg",
  icon"mdi/battery-40.svg",
  icon"mdi/battery-50.svg",
  icon"mdi/battery-60.svg",
  icon"mdi/battery-70.svg",
  icon"mdi/battery-80.svg",
  icon"mdi/battery-90.svg",
  icon"mdi/battery.svg",
  icon"mdi/battery-charging-10.svg",
  icon"mdi/battery-charging-20.svg",
  icon"mdi/battery-charging-30.svg",
  icon"mdi/battery-charging-40.svg",
  icon"mdi/battery-charging-50.svg",
  icon"mdi/battery-charging-60.svg",
  icon"mdi/battery-charging-70.svg",
  icon"mdi/battery-charging-80.svg",
  icon"mdi/battery-charging-90.svg",
  icon"mdi/battery-charging-100.svg",
}--}}}

local seticon = function(w, percent, ischarging)--{{{
  local iconidx =--{{{
    (percent == 0 and 1) or
    (ceil(percent / 10))
  iconidx =
    (ischarging and iconidx + 10) or
    (iconidx)--}}}
  local icon = batteryicons[iconidx]
  local iconcolor =--{{{
    (percent > 70 and beautiful.color2) or
    (percent > 40 and beautiful.color3) or
    (percent > 20 and beautiful.color1) or
    (beautiful.color1) or
    ("#ffffff")--}}}
  coloredicon =
    gears.color.recolor_image(icon, iconcolor)
  w.image = coloredicon
end--}}}

local btext = wibox.widget {--{{{
  widget = wibox.widget.textbox,
  markup = 'hello world',
  halign = 'center',
  font = 'sans 10',
}--}}}

local bicon = wibox.widget{--{{{
  widget = wibox.widget.imagebox,
  image = icon"battery-100.svg",
}--}}}

local choseindex = function(percent, charging)--{{{
  local idx =
    (percent > 90 and 10) or
    ceil(percent / 10)
  return charging and idx + 10 or idx
end--}}}

local bmarkup = "<span color='#000000'><b>%s</b></span>"--{{{
local callback = function()
  local percentage = upower:percentage()
  local charging = upower:ischarging()
  local idx = choseindex(percentage, charging)

  btext.markup = string.format("<i>%d%%</i>", percentage)
  seticon(bicon, percentage, charging)
end
callback()--}}}

upower.watch(callback)

return wibox.widget{--{{{
  widget = wibox.container.margin,
  margins = beautiful.wibar_width / 8,
  {
    widget = wibox.layout.fixed.vertical,
    wibox.container.place(btext),
    bicon,
  }
}--}}}
