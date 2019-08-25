local awful = require("awful")
local gears = require("gears")

local BRIGHTNESS_GET  = "light"
local BRIGHTNESS_UP   = "light -A 10"
local BRIGHTNESS_DOWN = "light -U 10"

local BRIGHTNESS_DOWN_KEY = "XF86MonBrightnessDown"
local BRIGHTNESS_UP_KEY   = "XF86MonBrightnessUp"

local brightness = {
	key = {},
	level = 30,
	widget = {},
	signal = { update = "brightness::update" }
}

function brightness.set_step(step)
	BRIGHTNESS_UP   = "light -A " .. step
	BRIGHTNESS_DOWN = "light -U " .. step
end

function brightness.update()
	awful.spawn.easy_async(BRIGHTNESS_GET, function(stdout)
		brightness.level = math.floor(tonumber(stdout) + 0.5)
		for i=1,#brightness.widget do
			brightness.widget[i]:emit_signal(brightness.signal.update, brightness.level)
		end
	end)
end

function brightness.decrease()
	awful.spawn.easy_async(BRIGHTNESS_DOWN, brightness.update)
end

function brightness.increase()
	awful.spawn.easy_async(BRIGHTNESS_UP, brightness.update)
end

function brightness.attach(widget, callback)
	table.insert(brightness.widget, widget)
	brightness.update()
	if type(callback) == "function" then callback() end
end

brightness.key = gears.table.join(
	awful.key({}, BRIGHTNESS_DOWN_KEY, brightness.decrease),
	awful.key({}, BRIGHTNESS_UP_KEY, brightness.increase)
) -- keybinding

return brightness
