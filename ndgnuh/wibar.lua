local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local widget = require("wibox.widget")
local layout = require("wibox.layout")
local container = require("wibox.container")
local lib = require("lib")
local wibox = require("wibox")

local menu_item = function(widget_config)
    local buttons = widget_config.buttons
    local margins = widget_config.margins or 4
    local tooltip = widget_config.tooltip
    widget_config.tooltip = nil
    widget_config.buttons = nil
    widget_config.margins = nil


    local widget = {
        widget = lib.widgets.background,
        hover_bg = '#3498DB',
        buttons = buttons,
        {
            widget = container.margin,
            margins = beautiful.xresources.apply_dpi(margins),
            widget_config,
        }
    }

    if tooltip then
        widget = wibox.widget(widget)
        local tooltip_wb = awful.tooltip({
            margins = beautiful.xresources.apply_dpi(4),
            mode = "outside",
            text = tooltip,
            preferred_positions = { "top" },
        })
        tooltip_wb:add_to_object(widget)
    end

    return widget
end

--- Setup a wibar on a screen
-- The setup args should be a table.
--- @param screen screen: awesome screen object
local setup = function(args)
    local screen = args.screen
    local position = args.position or "bottom"

    local wibar = awful.wibar {
        screen = screen,
        position = position,
        stretch = true,
    }

    -- wibar left item
    local left = {
        widget = layout.fixed.horizontal,
        menu_item { -- because layout  box does not support declarative
            widget = layout.fixed.horizontal,
            awful.widget.layoutbox(screen),
            margins = 4,
        },
        menu_item {
            tooltip = "Open file manager",
            widget = wibox.widget.imagebox,
            image = lib.icon("assets/icons/folder.svg", "#F1C40F"),
            buttons = awful.button({}, 1, function() awful.spawn.raise_or_spawn("Thunar") end),
        },
        menu_item {
            tooltip = "Open web browser",
            widget = wibox.widget.imagebox,
            image = lib.icon("assets/icons/globe.svg", "#3498DB"),
            buttons = awful.button({}, 1, function() awful.spawn.raise_or_spawn("firefox") end),
        },
        require("ndgnuh.tasklist").setup { screen = screen },
    }

    -- wibar right item
    local right = {
        widget = layout.fixed.horizontal,
        spacing = beautiful.xresources.apply_dpi(4),
        menu_item {
            {
                widget = wibox.widget.imagebox,
                image = lib.icon("assets/icons/keyboard.svg", beautiful.fg_focus),
            },
            {
                widget = require("ndgnuh.ibus"),
                format = "longname",
            },
            widget = wibox.layout.fixed.horizontal,
            spacing = beautiful.xresources.apply_dpi(4),
            buttons = gears.table.join(
                awful.button({}, 1, function() ic { ibus_cycle = "Implement me" } end),
                awful.button({}, 3, function() awful.spawn.raise_or_spawn("ibus-setup") end)
            ),
        },
        menu_item {
            widget = require("ndgnuh.network_indicator"),
        },
        menu_item { widget = widget.systray, screen = screen, margins = 2, buttons = {} },
        menu_item {
            widget = widget.textclock,
            format = lib.text_color("%H:%M %a, %d/%m/%Y", beautiful.fg_focus),
        },
        menu_item { widget = require("ndgnuh.visible_indicator"), buttons = awful.button({}, 1, lib.workflow.view_none), },
    }

    -- wibar setup
    wibar:setup {
        left, nil, right,
        widget = layout.align.horizontal,
        spacing = beautiful.xresources.apply_dpi(8),
    }
end

return { setup = setup }
