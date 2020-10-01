local re = require
local lgi = require"lgi"
local wibox =require"wibox"
local beautiful =require"beautiful"
local awful =require"awful"
local gears =require"gears"
local sh =require"sh"

local ok, UPower = pcall(lgi.require, "UPowerGlib")

if not ok then
  dump("Please install upower")
  return {
	  percentage = function() return 0 end,
	  ischarging = function() return false end,
	  isfull = function() return false end,
	  watch = function() end
  }
end

local upower_client = UPower.Client()

local module = { display_device = upower_client:get_display_device() }

--- set initial status, very long piece of code
module.battery = {
  percentage = module.display_device.percentage,
  -- battery_level = module.display_device.battery_level,
  capacity = module.display_device.capacity,
  energy = module.display_device.energy,
  energy_empty = module.display_device.energy_empty,
  energy_full = module.display_device.energy_full,
  energy_full_design = module.display_device.energy_full_design,
  energy_rate = module.display_device.energy_rate,
  -- has_history = module.display_device.has_history,
  -- has_statistics = module.display_device.has_statistics,
  icon_name = module.display_device.icon_name,
  is_present = module.display_device.is_present,
  -- is_rechargeable = module.display_device.is_rechargeable,
  kind = module.display_device.kind,
  -- luminosity = module.display_device.luminosity,
  model = module.display_device.model,
  -- native_path = module.display_device.native_path,
  online = module.display_device.online,
  percentage = module.display_device.percentage,
  power_supply = module.display_device.power_supply,
  -- serial = module.display_device.serial,
  state = module.display_device.state,
  -- technology = module.display_device.technology,
  temperature = module.display_device.temperature,
  time_to_empty = module.display_device.time_to_empty,
  time_to_full = module.display_device.time_to_full,
  update_time = module.display_device.update_time,
  vendor = module.display_device.vendor,
  voltage = module.display_device.voltage,
  warning_level = module.display_device.warning_level,
}
---

module.watch = function(callback)
  module.display_device.on_notify = function(dev, gstat)
    module.battery.state_string = dev.state_to_string(dev.state)
    module.battery.state = dev.state
    module.battery.percentage = dev.percentage
    if module.battery.state_string == "Charging" then
      module.battery.time = device.time_to_full
    elseif module.battery.state_string == "Discharging" then
      module.battery.time = device.time_to_empty
    else
      module.battery.time = 0
    end
    callback(module.battery, dev, gstat)
  end
end

--[[
[upower.DeviceState.PENDING_DISCHARGE] = "Discharging",
[upower.DeviceState.PENDING_CHARGE]    = "Charging",
[upower.DeviceState.FULLY_CHARGED]     = "Full",
[upower.DeviceState.EMPTY]             = "N/A",
[upower.DeviceState.DISCHARGING]       = "Discharging",
[upower.DeviceState.CHARGING]          = "Charging",
[upower.DeviceState.UNKNOWN]           = "N/A"
]]
module.ischarging =
function(self)
  local state = self.battery.state
  return
  state == UPower.DeviceState.PENDING_CHARGE or
  state == UPower.DeviceState.CHARGING or
  state == UPower.DeviceState.FULLY_CHARGED
end

module.isfull =
  function(self)
    return
      self.battery.state == upower.DeviceState.FULLY_CHARGED
  end

  module.getstate = function (self)
    return self.battery.state_string
  end

  module.percentage = function(self)
    return self.battery.percentage
  end

return module

