--- Define custom max layout, this layout does not display borders.
-- Gaps are ignored in this layout. When client are focused,
-- they are always raised. I write custom layout because the clients
-- that are floating are not passed to them, therefore I can disable
-- border for tiling clients only.
local capi = { client = client }
local max = { name = "max" }

-- Arange clients on the screen
function max.arrange(p)
    local gap = p.useless_gap
    local geo = p.workarea

    -- smart border stuff
    for _, c in ipairs(p.clients) do
        c.border_width = 0
        p.geometries[c] = {
            x = geo.x - (c.border_width + gap) * 2,
            y = geo.y - (c.border_width + gap) * 2,
            width = geo.width + 4 * (c.border_width + gap),
            height = geo.height + 4 * (c.border_width + gap),
        }
        if c == capi.client.focus then
            c:raise()
        end
    end
end

--- Skip every gaps
function max.skip_gap(nclients, t) -- luacheck: no unused args
    return true
end

return max
