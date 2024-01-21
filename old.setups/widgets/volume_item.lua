local slider = rrequire("volume_slider", ...)
local label = rrequire("volume_label", ...)
local revealer = rrequire("volume_label", ...)
local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")
local awful = require("awful")
local image = require("images")
local capi = { awesome = awesome }
local iconbox = require("widgets.iconbox")
local volume = require("lib.volume")
local gears = require("gears")

local function get_image_icon(status)
    if status.mute or status.volume <= 5 then
        return resource("assets/icons/volume_mute.svg")
    elseif status.volume <= 30 then
        return resource("assets/icons/volume_down.svg")
    elseif status.volume <= 60 then
        return resource("assets/icons/volume_up.svg")
    else
        return resource("assets/icons/volume_up.svg")
    end
end

local w = widget {
	widget = layout.fixed.vertical,
	spacing = 4,
	-- container.place(label),
    {
        widget = require("lib.widgets.background"),
        hover_bg = "#616161",
        {
            widget = container.margin,
            margins = 8,
            {
                id = "icon",
                widget = widget.imagebox,
                image = resource("./assets/icons/volume_up.png"),
            },
        },
    },
	slider,
}

capi.awesome.connect_signal("extra::volume", function(vol)
    local icon_widget = w:get_children_by_id("icon")[1]
    local icon = get_image_icon(vol)
    icon = gears.color.recolor_image(icon, "#FFFFFF")
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
