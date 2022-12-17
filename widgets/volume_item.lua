local image = rrequire("image", ...)
local slider = rrequire("volume_slider", ...)
local label = rrequire("volume_label", ...)
local revealer = rrequire("volume_label", ...)
local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")
local awful = require("awful")


local w = widget {
	widget = layout.fixed.vertical,
	spacing = 4,
	container.place(label),
	slider,
	image("volume-up.png", "#fff", 8),
}

slider.visible = false
w:connect_signal("mouse::enter", function()
	slider.visible = true
end)
w:connect_signal("mouse::leave", function()
	slider.visible = false
end)


return w
