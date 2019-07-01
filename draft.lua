local gears = require("gears")
local widget_volume = require("ggz.widget_volume")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")

local update_timer = gears.timer({
	timeout = 1,
	callback = function()
		naught.notify({ text = "Battery status changed" })
		awful.spawn.easy_async_with_shell("acpi -b", function(stdout)
			naught.notify({ text = tostring(stdout) })
		end)
	end,
	single_shot = true
})

awful.spawn.with_line_callback("upower --monitor-detail", {
	stdout = function(line)
		naughty.notify({ text = line })
		update_timer:again()
	end,
	stderr = function(e)
		naughty.notify({ text = tostring(e) })
	end
})
