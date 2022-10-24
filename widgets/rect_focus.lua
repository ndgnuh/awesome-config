local anime = require("lib.animate")
local throttle = require("lib.throttle")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local bg = beautiful.border_focus
local bw = beautiful.border_width

local rect = {
	left = wibox {
		x = 0,
		y = 0,
		width = bw,
		height = bw,
		bg = bg,
	},
	right = wibox {
		x = 0,
		y = 0,
		width = bw,
		height = bw,
		bg = bg,
	},
	top = wibox {
		x = 0,
		y = 0,
		width = bw,
		height = bw,
		bg = bg,
	},
	bottom = wibox {
		x = 0,
		y = 0,
		width = bw,
		height = bw,
		bg = bg,
	},
	disabled = true
}

function rect.get_geometry(self)
	local geo = {}
	for _, pos in ipairs({"top", "left", "right", "bottom"}) do
		local r = self[pos]
		for m, v in pairs(r:geometry()) do
			geo[pos .. "_" .. m] = v
		end
	end
	return geo
end

function rect.set_geometry(self, geo)
	for _, pos in ipairs({"top", "left", "right", "bottom"}) do
		local r = self[pos]
		for m, v in pairs(r:geometry()) do
			r[m] = geo[pos .. "_" .. m]
		end
	end
	return geo
end

function rect.geometry(self, geo)
	if geo == nil then
		return rect:get_geometry()
	else
		return rect:set_geometry(geo)
	end
end

function rect.visible(vis)
	if rect.disabled then vis = false end
	for _, k in pairs({"top", "left", "right", "bottom"}) do
		v = rect[k]
		v.ontop = vis
		v.visible = vis
	end
end

local function to_rect_geometry(g)
	return {
		-- left
		left_x = g.x,
		left_y = g.y,
		left_width = g.width,
		left_height = bw,
		-- top
		top_x = g.x,
		top_y = g.y,
		top_width = bw,
		top_height = g.height,
		-- right
		right_x = g.x + g.width,
		right_y = g.y,
		right_width = bw,
		right_height = g.height,
		-- bottom
		bottom_x = g.x,
		bottom_y = g.y + g.height,
		bottom_width = g.width,
		bottom_height = bw,
	}
end


-- local function set_geometry(rect, geo)
--	local g1 = rect:geometry()
--	local x2 = geo.x + geo.width
--	local y2 = geo.y + geo.height

--	-- top
--	rect.top.x = geo.x
--	rect.top.y = geo.y

--	--
--	rect.left.x = geo.x
--	rect.left.y = geo.y
--	rect.bottom.x = geo.x
--	rect.bottom.y = y2
--	rect.right.x = x2
--	rect.right.y = geo.y

--	-- width/height
--	rect.left.height = geo.height
--	rect.right.height = geo.height
--	rect.top.width = geo.width
--	rect.bottom.width = geo.width

--	-- visible
--	return geo
-- end

local callback_ = function(c)
	rect.visible(true)
	anime.easy_animate(rect, to_rect_geometry(c:geometry()), rect.set_geometry)
end
local callback = throttle(0.05, callback_)


client.connect_signal("property::geometry", function(c)
	callback(c)
end)

client.connect_signal("focus", callback)
client.connect_signal("unfocus", function(c)
	if  client.focus == nil then
		rect.visible(false)
	end
end)

return {
	disable = function() rect.disabled = (true) end,
	enable = function() rect.disabled = (false) end,
}
