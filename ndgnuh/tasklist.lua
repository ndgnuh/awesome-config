--- This module contains the customized tasklist
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local capi = { client = client }
local module = {}

--- Widget names
local icon_name = "icon"             -- avoid icon_role
local background_name = "background" -- avoid background_role

--- Task list changes callback
--- @param taskitem table: the task item widget
--- @param client table: the awesomewm client
--- @param index table: the client index
--- @param clients table: the list of clients
local create_callback = function(taskitem, client, index, clients) -- luacheck: no unused args
    -- Show full client name with tooltip
    awful.tooltip {
        markup = client.name,
        mode = "outside",
    }:add_to_object(taskitem)

    -- Setup high resolution icon
    local icon = taskitem:get_children_by_id(icon_name)[1]
    icon:set_client(client)

    -- Setup hover/press callback
    local bg = taskitem:get_children_by_id(background_name)[1]
    bg.hovering = false
    bg:connect_signal("mouse::enter", function() bg.hovering = true end)
    bg:connect_signal("mouse::leave", function() bg.hovering = false end)
    bg:connect_signal("mouse::enter", function() bg.bg = beautiful.bg_focus end)
    bg:connect_signal("mouse::leave", function() bg.bg = nil end)
    bg:connect_signal("button::press", function() bg.bg = beautiful.bg_focus end)
    bg:connect_signal("button::release", function()
        bg.bg = bg.hovering and beautiful.bg_focus or nil
    end)
end

--- [[ Task item template ]]
local line_height = beautiful.xresources.apply_dpi(3)
local widget_template = {
    widget = wibox.container.background,
    id = background_name,
    {
        widget = wibox.layout.stack,
        {
            widget = wibox.container.margin,
            margins = beautiful.xresources.apply_dpi(7),
            {
                widget = wibox.layout.fixed.horizontal,
                spacing = beautiful.xresources.apply_dpi(4),
                {
                    widget = awful.widget.clienticon,
                    id = icon_name,
                },
                {
                    id = "text_role",
                    widget = wibox.widget.textbox,
                },
            },
        },
        {
            widget = wibox.layout.fixed.vertical,
            {
                wibox.widget.textbox(""), -- the background container of stable awesome needs this to display
                widget = wibox.container.background,
                forced_height = line_height,
                id = "background_role",
            },
        }
    },
    create_callback = create_callback,
}

--- Task list buttons
local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == capi.client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

--- Setup tasklist
--- @param screen table: awesome screen object
module.setup = function(args)
    local screen = args.screen

    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            layout = wibox.layout.flex.horizontal,
            spacing = beautiful.xresources.apply_dpi(8),
        },
        widget_template = widget_template,
    }
end


return module
