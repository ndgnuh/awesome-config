local awful = require("awful")
local beautiful = require("beautiful")
local tile = {}
local max_layout = require("max_layout")

local function truefloating(c)
	-- local result
	-- if cache then
	--	result = cache[c]
	-- end
	return (c.floating and not (c.maximized and c.fullscreen))
end

tile.name = "tile"
tile.resize_jump_to_corner = true
tile.mouse_resize_handler = awful.layout.suit.tile.right.mouse_resize_handler
local function tile_recursively(p, n, i)
	if n == 1 then
		return max_layout.arrange(p)
	end
	i = i or 1
	dump({ p, n })
end

local function do_tile(param)
	local t = param.tag or screen[param.screen].selected_tag
	local useless_gap = param.useless_gap
	local gs = param.geometries
	local cls = param.clients
	local nmaster = math.min(t.master_count, #cls)
	local nother = math.max(#cls - nmaster, 0)
end

local function do_tile(p)
	-- prepare
	local t = p.tag or screen[p.screen].selected_tag
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
		-- c.shape = require("gears.shape").rounded_rect
	end
end

function tile.arrange(p)
	ok, err = pcall(do_tile, p)
	if not ok then
		dump(err)
	end
end

tile.arrange = do_tile

return tile
