local awful = require("awful")

local beautiful = require("beautiful")

local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")

local gears = require("gears")

local shape = require("gears.shape")
local color = require("gears.color")
local image = require("images")
local state = require("lib/pomodoro")

local capi = {
    awesome = awesome,
    root = root,
    client = client
}


local function icon_widget(...)
	return widget{
        widget = widget.imagebox,
        image = image("tomato.png")
    }
end

local function main_widget(state)
    local times = {5, 15, 30, 45, 50}
    local labels = {
        widget = layout.fixed.vertical
    }


    for _, time in ipairs(times) do
        local label = widget.textbox(tostring(time) .. ":00")
        label:connect_signal("button::pressed", function()
            state.seconds_left = time * 60
            state.is_active = true
        end)
        labels[#labels + 1] = label
    end
    local main = widget{
        widget = container.background,
        bg = "#FFF",
        labels,
    }
    return main
end

local function panel_widget(...)
    local popup = awful.popup{
        widget = pdump(main_widget, nil),
        ontop = true,
        visible = false,
        screen = s,
    }
    return popup
end


local function pomodoro(s)
    local icon = icon_widget(s)
    local panel = panel_widget(s)
    panel:bind_to_widget(icon)


    state:bind_widget(panel)
    icon:connect_signal("button::press", function(self)
        state.is_panel_active = not state.is_panel_active

        -- update everything accordingly
        panel.visible = state.is_panel_active
        panel.ontop = state.is_panel_active
    end)

    return icon
end

return pomodoro
