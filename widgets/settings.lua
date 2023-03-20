local image = require("images")
local awful = require("awful")

local beautiful = require("beautiful")

local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")

local gears = require("gears")

local shape = require("gears.shape")
local color = require("gears.color")
local form_widget = require("lib.form_widgets")
local settings = require("lib.settings")

local capi = {
    awesome = awesome,
    root = root,
    client = client
}

-- THE CONFIG
local state = { panel_on = false}

-- [[ VIEW ]]

local widgets = {}

widgets.panel = awful.popup{
    widget = widget{
        widget = layout.fixed.vertical,
    },
    ontop = true,
    visible = false,
    hide_on_right_click = true,
}

local inputs = {}
for key, value in pairs(settings) do
    if type(value) ~= "function" then
        local input = form_widget.text_input{ label = key, value = value, callback = settings.set_fn(key)}
        inputs[#inputs + 1] = input
    end
end

widgets.panel.widget = widget {
    widget = layout.fixed.vertical,
    widget.textbox("<b># Settings</b>"),
    form_widget.list_inputs(inputs)
}

widgets.icon = widget{
    widget = widget.imagebox,
    image = image("ics/settings.png")
}


-- [[ CONTROLS]]
widgets.panel:bind_to_widget(widgets.icon)
widgets.icon:connect_signal('button::press', function(self)
    state.panel_on = not state.panel_on
    widgets.panel.visible = state.panel_on
end)

return function(s)
    return widgets.icon
end
