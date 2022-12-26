-- local revealer = rrequire("revealer", ...)
local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")
local beautiful = require("beautiful")
local shape = require("gears.shape")
local color = require("gears.color")
local awful = require("awful")

local capi = {
    awesome = awesome,
    root = root,
    client = client
}

local throttle = require("lib.throttle")
local delayed = throttle.delayed
local throttle = throttle.throttle

local the_slider = widget{
    bar_shape= shape.rounded_rect,
    bar_height= 3,
    handle_color= beautiful.bg_focus,
    handle_shape= shape.circle,
    bar_active_color = beautiful.bg_focus,
    bar_color = beautiful.fg_normal,
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    value = 0,
    maximum = 150,
    minimum = 0,
    widget = widget.slider,
    lock = false
}

local slider = widget{
    widget = container.background,
    -- bg="#f00",
    {
        widget = container.rotate,
        the_slider,
        direction= "east",
        forced_height=150
    }
}

the_slider:connect_signal("property::value", throttle(0.01, function(self)
    self.lock = true
    awful.spawn.easy_async_with_shell(
        "pactl set-sink-volume @DEFAULT_SINK@ " .. self.value .. "% && sleep 0.5", function()
        self.lock = false
    end)
end))

capi.awesome.connect_signal("extra::volume", function(volume)
    if not the_slider.lock then
        the_slider.lock = true
        the_slider.value = volume.volume
        the_slider.lock = false
    end
end)
return slider
