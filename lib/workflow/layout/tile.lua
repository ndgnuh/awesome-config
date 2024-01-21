--- This module defines custom tile layout
-- TODO: I forgot why this layout is different from the original one
-- Maybe it is because when no client is there, it uses the custom max
-- layout.
local awful = require("awful")
local beautiful = require("beautiful")
local max_layout = require("lib.workflow.layout.max")
local capi = { screen = screen }

--- Inherit from the "tile.right" layout of AwesomeWM
local tile = {
    name = "tile",
    resize_jump_to_corner = true,
    mouse_resize_handler = awful.layout.suit.tile.right.mouse_resize_handler,
    border_width = beautiful.border_width,
}


--- Arrange the client on the screens
-- This is awesomeWM API function
tile.arrange = function(p)
    -- prepare
    local t = p.tag or capi.screen[p.screen].selected_tag
    local ntile = #p.clients
    local mcount = t.master_count
    local ncount = ntile - mcount -- non master
    local geo = p.workarea
    local gap = p.useless_gap

    -- no tiled, return
    if ntile == 0 then
        return
    end

    -- single tiled client
    if ntile == 1 then
        for _, c in ipairs(p.clients) do
            c.border_width = 0
            c.shape = nil
            p.geometries[c] = {
                x = geo.x - (c.border_width + gap) * 2,
                y = geo.y - (c.border_width + gap) * 2,
                width = geo.width + 4 * (c.border_width + gap),
                height = geo.height + 4 * (c.border_width + gap),
            }
        end
        return
    end

    -- multiple tiled

    -- master width factor
    local mwfact
    if mcount == 0 then
        mwfact = 0
    elseif ncount == 0 then
        mwfact = 1
    else
        mwfact = t.master_width_factor
    end

    -- master geometry
    local m_y = geo.y + gap
    local m_x = geo.x + gap
    local m_w = geo.width * mwfact
    local m_h = (geo.height - gap * (mcount + 1)) / mcount

    -- non-master geometry
    local n_x = geo.x + m_w + gap
    local n_y = geo.y + gap
    local n_w = geo.width * (1 - mwfact) - gap
    local n_h = (geo.height - gap * (ncount + 1)) / ncount

    -- loop throught and set
    for j, c in ipairs(p.clients) do
        if j <= mcount then
            p.geometries[c] = {
                x = m_x,
                y = m_y,
                width = m_w,
                height = m_h,
            }
            m_y = m_y + m_h + gap
        else
            p.geometries[c] = {
                x = n_x,
                y = n_y,
                width = n_w,
                height = n_h,
            }
            n_y = n_y + n_h + gap
        end
        c.border_width = beautiful.border_width
    end
end

--- Should skip gap on the layout
--- @param nclients number: Number of the client
--- @param tag table: AwesomeWM tag
function tile.skip_gap(nclients, tag) -- luacheck: no unused args
    return #nclients <= 1
end

return tile
