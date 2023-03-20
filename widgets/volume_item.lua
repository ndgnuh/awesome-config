local slider = rrequire("volume_slider", ...)
local label = rrequire("volume_label", ...)
local revealer = rrequire("volume_label", ...)
local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")
local awful = require("awful")
local image = require("images")
local capi = {awesome = awesome}

local function get_image_icon(status)

	local volume = status.volume
	local icon = "ics/volume-"
	if status.mute or volume <= 5 then
		icon = icon .. "0"
	elseif volume <= 30 then
		icon = icon .. "1"
	elseif volume <= 60 then
		icon = icon .. "2"
	else
		icon = icon .. "3"
	end


	icon = icon .. ".png"
	return icon
end

local icon_widget = widget{
	widget = widget.imagebox,
	image = image("ics/volume-3.png", "#fff")
}

local w = widget {
	widget = layout.fixed.vertical,
	spacing = 4,
	-- container.place(label),
	slider,
	icon_widget
}

capi.awesome.connect_signal("extra::volume", function(volume)
	local icon = image(get_image_icon(volume))
	icon_widget:set_image(icon)
end)
slider.visible = false
w:connect_signal("mouse::enter", function()
	slider.visible = true
end)
w:connect_signal("mouse::leave", function()
	slider.visible = false
end)


return w
