-- This module define the customized workflow
-- The workflow is very similar to the one by gnome, where
-- only one tag is defined by default, other tags are created
-- when they are needed. The created tags are volatile, if no
-- clients are there, they are deleted.
-- This module aim to create most "natural feeling" to each
-- actions as possible.
local awful = require("awful")
local gears = require("gears")
local capi = { client = client, screen = screen } -- luacheck: ignore

local m = {
    layout = require("lib.workflow.layout")
}

--- Get information about current tag
--- @return number: the current tag index
--- @return number: the current number of tags
local tag_metrics = function()
    local screen = awful.screen.focused()
    local tags = screen.tags
    local num_tags = #tags
    local idx = gears.table.hasitem(tags, screen.selected_tag)
    return idx, num_tags
end

--- View the previous tag
-- Implemented as a separate function just in case I wanted to change things
m.view_previous_tag = function()
    awful.tag.viewprev()
end

--- Move client to previous tag
-- If the first tag is selected, does nothing
m.move_to_previous_tag = function()
    local client = capi.client.focus
    if not client then return end
    local i, n = tag_metrics()
    if i <= 1 then return end
    client:move_to_tag(client.screen.tags[i - 1])
end

--- Move the current client to next tag
-- If the next tag does not exists, create a new one
m.move_to_next_tag = function()
    local client = capi.client.focus
    local screen = awful.screen.focused()
    if not client then return end
    m.view_next_tag()
    client:move_to_tag(screen.selected_tag)
end

--- View the next tag.
-- If the current tag is the last one, create a volatile tag.
-- The new tag inherit the current tag's layout.
m.view_next_tag = function()
    local screen = awful.screen.focused()
    local i, n = tag_metrics()
    if i == n then
        local name = tostring(n)
        local current_tag = screen.selected_tag
        awful.tag.add(name, {
            screen = screen,
            layout = current_tag.layout,
            volatile = true,
        })
    end
    awful.tag.viewnext()
end


--- Show the wallpaper
-- This function toggle between view none and previous tag.
-- When it does, it emits tag history update to notify tag related features
m.view_none_state = { previous = nil }
m.view_none = function()
    local screen = awful.screen.focused()
    local state = m.view_none_state
    if state.previous == nil then
        state.previous = screen.selected_tag
        awful.tag.viewnone()
    else
        awful.tag.viewonly(state.previous)
        state.previous = nil
    end
    capi.screen.emit_signal("tag::history::update", screen)
end

--- Setup the workflow
-- This is needed to handle signal related features
m.setup = function()
    -- Force delete residual empty volatile tags
    capi.screen.connect_signal("tag::history::update", function(screen)
        for _, tag in ipairs(screen.tags) do
            if tag.volatile and not tag.selected then
                tag:delete()
            end
        end
    end)

    -- Enable titlebar on floating clients ONLY
    capi.client.connect_signal("property::floating", function(client)
        if client.floating then
            awful.titlebar.show(client)
        else
            awful.titlebar.hide(client)
        end
    end)
end

return m
