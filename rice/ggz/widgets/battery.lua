local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local UPower = require"model.upower"
local api = require("api")
local naughty = require("naughty")

local battery_text = wibox.widget({
   widget = wibox.widget.textbox,
   markup = beautiful.whitetext("80/100"),
   font = beautiful.boldfontsmall,
   align = "center"
})

local battery_bar = wibox.widget({
   max_value = 100,
   value = 10,
   widget = wibox.widget.progressbar,
   shape = gears.shape.rounded_bar
})

local battery_widget = wibox.widget({
   battery_bar,
   battery_text,
   layout = wibox.layout.stack,
})

local updatefunction = function(bat)
  local percentage = UPower:percentage()
  battery_bar.value = percentage
  local status_text = tostring(percentage):match("%d%d%d?") .. "% " .. (UPower:getstate() or 'Unknown')
  battery_text.markup = beautiful.whitetext(status_text)
end

UPower.watch(updatefunction)
updatefunction()
--battery_bar:connect_signal(api.battery.signal.update, function(_, device)
--   battery_bar.value = device.percentage
--   local status_text = math.floor(device.percentage + 0.5) .. "/100 ".. api.battery.status[device.state]
--   battery_text.markup = beautiful.whitetext(status_text)
--   if device.percentage < 50 then
--      naughty.notification {
--         preset  = naughty.config.presets.critical,
--         message = "Low battery, percentage left: " .. tostring(device.percentage) .. "%",
--         title   = "Warning"
--      }
--   end
--end)
--api.battery.attach(battery_bar)
return battery_widget
