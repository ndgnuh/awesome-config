local wibox = require("wibox")
local lgi = require("lgi")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local has_upower, upower = pcall(lgi.require, "UPowerGlib")
local resource = require("lib.resource")

local BatteryIcon = {}

local normal_bg = resource.hsl(90, 0.3, 0.3, 0.9)
local hover_bg = resource.hsl(90, 0.35, 0.35, 0.9)
local active_bg = resource.hsl(90, 0.25, 0.25, 0.9)

beautiful.gutter = beautiful.gutter or 8
local DeviceState = upower.DeviceState

local STATES = {
	[DeviceState.PENDING_DISCHARGE] = "Pending discharge",
	[DeviceState.PENDING_CHARGE] = "Pending charge",
	[DeviceState.FULLY_CHARGED] = "Full",
	[DeviceState.EMPTY] = "Empty",
	[DeviceState.DISCHARGING] = "Discharging",
	[DeviceState.CHARGING] = "Charging",
	[DeviceState.UNKNOWN] = "Unknown",
}

--- How many time until charge/deplete
local seconds_to_time = function(seconds)
	if seconds <= 0 then
		return "00:00:00"
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
		return hours .. ":" .. mins .. ":" .. secs
	end
end

local function state_string(state)
	local state_str
	if has_upower then
		local lookup = {
			[upower.DeviceState.PENDING_DISCHARGE] = "Discharging",
			[upower.DeviceState.PENDING_CHARGE] = "Charging",
			[upower.DeviceState.FULLY_CHARGED] = "Full",
			[upower.DeviceState.EMPTY] = "Empty",
			[upower.DeviceState.DISCHARGING] = "Discharging",
			[upower.DeviceState.CHARGING] = "Charging",
			[upower.DeviceState.UNKNOWN] = "Unknown",
		}
		state_str = lookup[state]
	else
		state_str = "UPowerGlib not found"
	end
	return state_str
end

local function _icon_name(pct, charging)
	local icon = "battery_"
	if charging == true then
		icon = icon .. "charging_"
	end

	local markers = { 10, 20, 30, 50, 60, 80, 90, 99 }
	local i = #markers
	repeat
		local marker = markers[i]
		if pct >= marker then
			icon = icon .. tostring(marker) .. ".svg"
			return icon
		end
		i = i - 1
	until i == 1

	--- Fallback
	icon = icon .. tostring(markers[1]) .. ".svg"
	return icon
end

function BatteryIcon.new()
	local proxy = wibox.widget({
		widget = require("lib.widgets.InkWell"),
		normal_bg = normal_bg,
		hover_bg = hover_bg,
		active_bg = active_bg,
		shape = gears.shape.rounded_rect,
		{
			widget = wibox.container.place,
			{
				widget = wibox.container.margin,
				left = beautiful.gutter / 4,
				top = beautiful.gutter / 4,
				bottom = beautiful.gutter / 4,
				right = beautiful.gutter / 2,
				id = "child",
				{
					widget = wibox.layout.fixed.horizontal,
					{
						widget = wibox.widget.imagebox,
						id = "icon",
					},
					{
						id = "text",
						widget = wibox.widget.textbox,
						markup = "100%",
						font = "sans bold 9",
					},
				},
			},
		},
	})

	local container = proxy:get_children_by_id("child")[1]
	local icon = proxy:get_children_by_id("icon")[1]
	local text = proxy:get_children_by_id("text")[1]

	local ret = wibox.widget.base.make_widget(proxy, "ndgnuh.widgets.BatteryIcon", {
		enable_property = true,
		-- class = layout_class,
	})
	gears.table.crush(ret, BatteryIcon, true)

	--- Initialize tooltip
	local tooltip = awful.tooltip({})
	tooltip:add_to_object(ret)
	tooltip:set_text("Battery information: Unknown")

	--- Save the children
	ret._private.tooltip = tooltip
	ret._private.text = text
	ret._private.icon = icon
	ret._private.container = container

	--- Save width
	-- function text:draw(context, cr, width, height)
	-- 	if not ret._private.text_width ~= width then
	-- 		ret._private.text_width = width
	-- 		ret:emit_signal("widget::layout_changed")
	-- 	end
	-- 	wibox.widget.textbox.draw(text, context, cr, width, height)
	-- end
	-- function icon:draw(context, cr, width, height)
	-- 	if not ret._private.text_width ~= width then
	-- 		ret._private.text_width = width
	-- 		ret:emit_signal("widget::layout_changed")
	-- 	end
	-- 	ret._private.icon_width = width
	-- 	wibox.widget.imagebox.draw(icon, context, cr, width, height)
	-- end

	-- Get UPower display device
	local device = upower.Client():get_display_device()
	ret._private.device = device

	--- What to run when battery changes
	local function update()
		-- get battery information
		local percentage = device.percentage
		local state = device.state

		-- set widget information
		text:set_text(tostring(percentage) .. "%")

		local charging = state == DeviceState.PENDING_CHARGE or state == DeviceState.CHARGING
		local icon_name = _icon_name(percentage, charging)
		icon:set_image(resource.icon("assets/icons/battery/" .. icon_name, "#fff"))

		-- set tooltip text
		local seconds_left = seconds_to_time(charging and device.time_to_full or device.time_to_empty)
		local tooltip_text = (
			"∘ Percentage: "
			.. percentage
			.. "%"
			.. "\n"
			.. "∘ Time to "
			.. (charging and "full" or "empty")
			.. ": "
			.. seconds_left
			.. "\n"
			.. "∘ Device status: "
			.. STATES[device.state]
			.. "\n"
			.. "∘ Discharge rate: "
			.. device.energy_rate
			.. "W"
		)
		tooltip:set_text(tooltip_text)
	end

	-- run update once, and watch for changes
	update()
	device.on_notify = update

	return ret
end

return setmetatable(BatteryIcon, {
	__call = function()
		return BatteryIcon.new()
	end,
})
