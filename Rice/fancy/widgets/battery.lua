local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local api = require("api")
local naughty = require("naughty")
local icondir = beautiful.icondir

local function geticon(p, stat)
   local iconname = "stat_sys_battery_"
   if stat == "charging" then
      iconname = iconname .. "charge_anim"
   end
   iconname = iconname .. math.floor(p + 0.5) .. ".png"
   return icondir .. iconname
end

local battery_widget = wibox.widget({
      widget = wibox.widget.imagebox,
      image = icondir .. geticon(20)
})

battery_widget:connect_signal(api.battery.signal.update, function(_, device)
   battery_widget.image = geticon(device.percentage, api.battery.status[device.state])
   if device.percentage < 50 then
      naughty.notification {
         preset  = naughty.config.presets.critical,
         message = "Low battery, percentage left: " .. tostring(device.percentage) .. "%",
         title   = "Warning"
      }
   end
end)

api.battery.attach(battery_widget)
return battery_widget
