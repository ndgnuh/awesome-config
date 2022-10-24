local anime = require("lib.animate")
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

function rect.geometry(self)
	return {
		y = self.top.y,
		x = self.left.x,
		width = self.top.width,
		height = self.left.width,
	}
end

function rect.visible(vis)
	if rect.disabled then vis = false end
	for _, k in pairs({"top", "left", "right", "bottom"}) do
		v = rect[k]
		v.ontop = vis
		v.visible = vis
	end
end


local function set_geometry(rect, geo)
	local g1 = rect:geometry()
	local x2 = geo.x + geo.width
	local y2 = geo.y + geo.height
	rect.top.x = geo.x
	rect.top.y = geo.y
	rect.left.x = geo.x
	rect.left.y = geo.y
	rect.bottom.x = geo.x
	rect.bottom.y = y2
	rect.right.x = x2
	rect.right.y = geo.y

	-- width/height
	rect.left.height = geo.height
	rect.right.height = geo.height
	rect.top.width = geo.width
	rect.bottom.width = geo.width

	-- visible
	return geo
end

local callback = function(c)
	rect.visible(true)
	gears.timer.delayed_call(anime.easy_animate, rect, c:geometry(), set_geometry)
end

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
