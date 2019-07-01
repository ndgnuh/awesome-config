------------------------------------------------------------------------
-- author ndgnuh
-- based on https://github.com/lexa/awesome_upower_battery
------------------------------------------------------------------------
local lgi = require ('lgi')
local UP = lgi.require('UPowerGlib')
local naughty = require ('naughty')

local battery = {
   signal = {
      update = "battery::update",
      attach = "battery::attach"
   },
   notifycation = {},
   status = {
      [UP.DeviceState.PENDING_DISCHARGE] = "pending discharge",
      [UP.DeviceState.PENDING_CHARGE]    = "pending charge",
      [UP.DeviceState.FULLY_CHARGED]     = "full",
      [UP.DeviceState.EMPTY]             = "empty",
      [UP.DeviceState.DISCHARGING]       = "discharging",
      [UP.DeviceState.CHARGING]          = "charging",
      [UP.DeviceState.UNKNOWN]           = "unknown",
   },
   widget = {}
}

function battery.update(device)
   for _,widget in ipairs(battery.widget) do
      widget:emit_signal(battery.signal.update, device)
   end
end

battery.client = UP.Client:new()
battery.display_device = battery.client:get_display_device()
if battery.display_device.is_present then
   -- try to find any other working device
   for _, d in ipairs(battery.client:get_devices()) do
      if d.is_present then
	 battery.display_device=d
	 break
      end
   end
   if not battery.display_device.is_present then
      return
   end
end

battery.display_device.on_notify = function(device)
   battery.update(device)
   if device.warning_level == UP.DeviceLevel.LOW
      or device.warning_level == UP.DeviceLevel.CRITICAL
      or device.warning_level == UP.DeviceLevel.ACTION
      or device.warning_level == UP.DeviceLevel.LAST
   then
      naughty.notify({
	 title = api.battery.notification.critical_title or "Warning",
	 text = battery.notification.critical_text or "Please connect your charger",
	 preset  = battery.notification.critical_preset or naughty.config.presets.critical
      })
   end
end

function battery.attach(widget)
   table.insert(battery.widget, widget)
   widget:emit_signal(battery.signal.update, battery.display_device)
end

return battery
