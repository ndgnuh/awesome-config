local beautiful = require("beautiful")
local max = {}

max.name = "max"

local function truefloating(c)
	return c.floating and not (c.maximized and c.fullscreen)
end

function max.arrange(p)
	local beautiful = require("beautiful")
	local gap = p.useless_gap
	local geo = p.workarea
	-- because the internal arrange function decrease x and y...
	-- local g = {
	-- 	x = geo.x - gap * 2,
	-- 	y = geo.y - gap * 2,
	-- 	width = geo.width + 4 * gap,
	-- 	height = geo.height + 4 * gap,
	-- }

	-- smart border stuff
	for _, c in ipairs(p.clients) do
		c.border_width = 0
		p.geometries[c] = {
			x = geo.x - (c.border_width + gap) * 2,
			y = geo.y - (c.border_width + gap) * 2,
			width = geo.width + 4 * (c.border_width + gap),
			height = geo.height + 4 * (c.border_width + gap),
		}
		if c == client.focus then
			c:raise()
		end
	end
end

function max.skip_gap(nclients, t) -- luacheck: no unused args
	return true
end

return max
