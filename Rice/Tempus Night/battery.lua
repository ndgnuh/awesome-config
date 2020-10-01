-- requires{{{
local upower = require"upower"
local wibox = require"wibox"
local gears = require"gears"
local icon = require"icon"
local beautiful = require"beautiful"--}}}

-- math lib{{{
local floor = math.floor
local ceil = math.ceil--}}}

-- default color {{{
local default = {
  color_full = "#00ff00",
  color_normal = "#ffff00",
  color_low = "#ff0000",
  color_charging_full = "#00ff00",
  color_charging_normal = "#ffff00",
  color_charging_low = "#ff0000",
}
---}}}

local batteryicons = {--{{{
  beautiful.battery_10_icon or icon"mdi/battery-10.svg",
  beautiful.battery_20_icon or icon"mdi/battery-20.svg",
  beautiful.battery_30_icon or icon"mdi/battery-30.svg",
  beautiful.battery_40_icon or icon"mdi/battery-40.svg",
  beautiful.battery_50_icon or icon"mdi/battery-50.svg",
  beautiful.battery_60_icon or icon"mdi/battery-60.svg",
  beautiful.battery_70_icon or icon"mdi/battery-70.svg",
  beautiful.battery_80_icon or icon"mdi/battery-80.svg",
  beautiful.battery_90_icon or icon"mdi/battery-90.svg",
  beautiful.battery_100_icon or icon"mdi/battery.svg",
  beautiful.battery_charging_10_icon or icon"mdi/battery-charging-10.svg",
  beautiful.battery_charging_20_icon or icon"mdi/battery-charging-20.svg",
  beautiful.battery_charging_30_icon or icon"mdi/battery-charging-30.svg",
  beautiful.battery_charging_40_icon or icon"mdi/battery-charging-40.svg",
  beautiful.battery_charging_50_icon or icon"mdi/battery-charging-50.svg",
  beautiful.battery_charging_60_icon or icon"mdi/battery-charging-60.svg",
  beautiful.battery_charging_70_icon or icon"mdi/battery-charging-70.svg",
  beautiful.battery_charging_80_icon or icon"mdi/battery-charging-80.svg",
  beautiful.battery_charging_90_icon or icon"mdi/battery-charging-90.svg",
  beautiful.battery_charging_100_icon or icon"mdi/battery-charging-100.svg",
}--}}}

-- set icon for widget {{{
local seticon = function(w, percent, ischarging)
  local iconidx =
    (percent == 0 and 1) or
    (ceil(percent / 10))
  if ischarging then
    iconidx = iconidx + 10
  end
  local icon = batteryicons[iconidx]
  local iconcolor =
    ischarging and
      (percent > 70 and
         beautiful.battery_color_charging_full or
         beautiful.battery_color_full or
         default.color_full) or
      (percent > 40 and
        beautiful.battery_color_charging_normal or
        beautiful.battery_color_normal or
        default.color_nomal) or
      (percent > 20 and
        beautiful.battery_color_charging_low or
        beautiful.battery_color_low or
        default.color_low) or
      ("#ffffff")
    or
      (percent > 70 and beautiful.battery_color_full or default.color_full) or
      (percent > 40 and beautiful.battery_color_normal or default.color_nomal) or
      (percent > 20 and beautiful.battery_color_low or default.color_low) or
      ("#ffffff")
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

local battery = wibox.widget{--{{{
  widget = wibox.container.margin,
  margins = beautiful.wibar_width / 8,
  {
    widget = wibox.layout.fixed.vertical,
    wibox.container.place(btext),
    bicon,
  }
}--}}}

return require"hoverbox"(battery)
