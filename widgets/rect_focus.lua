local animate = require("lib.animate")
local throttle = require("lib.throttle")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")

local bg = beautiful.border_focus
local bw = beautiful.border_width

local rect = {
	borders = {
		left = wibox({ bg = bg }),
		right = wibox({ bg = bg }),
		top = wibox({ bg = bg }),
		bottom = wibox({ bg = bg }),
	},
	disabled = true,

	geometry = function(self, geo)
		-- dump({ action = "rect geometry", geo = geo })
		if geo then
			for pos, border in pairs(self.borders) do
				border:geometry(geo[pos])
			end
		else
			geo = {}
			for pos, border in pairs(self.borders) do
				geo[pos] = border:geometry()
			end
			return geo
		end
	end,
}

function rect.visible(vis)
	-- if rect.disabled then
	--	vis = false
	-- end
	for pos, border in pairs(rect.borders) do
		border.ontop = vis
		border.visible = vis
	end
end

local get_border_width = gears.cache(function(bbw, bw)
	if bbw > 0 then
		return bbw
	end
	return bw
end)

local function to_rect_geometry(g)
	local bw = get_border_width:get(beautiful.border_width, 2)
	local rg = {
		-- left
		left = {
			x = g.x,
			y = g.y,
			height = g.height,
			width = bw,
		},
		-- top
		top = {
			x = g.x,
			y = g.y,
			width = g.width,
			height = bw,
		},

		-- right
		right = {
			x = g.x + g.width - bw,
			y = g.y,
			height = g.height,
			width = bw,
		},
		-- bottom
		bottom = {
			x = g.x,
			y = g.y + g.height - bw,
			width = g.width,
			height = bw,
		},
	}

	return rg
end

local callback = function()
	local c = client.focus
	if c == nil then
		rect.visible(false)
		return
	end
	local rg = to_rect_geometry(c:geometry())
	-- rect:geometry(rg)
	-- dump({ rg })
	-- if rect.disabled then
	-- 	return
	-- end
	rect.visible(true)
	ok, res = pcall(animate, {
		widget = rect,
		geometry = rg,
		animation = {
			intro = 0.05,
			duration = 0.15,
			override_dt = true,
		},
	})
	if not ok then
		dump(res)
		rect:geometry(rg)
	end
end
callback = throttle(0.025, callback)

client.connect_signal("property::geometry", function(c)
	callback(c)
end)

tag.connect_signal("focus", callback)
client.connect_signal("focus", callback)
client.connect_signal(
	"unfocus",
	throttle(0.025, function()
		local s = awful.screen.focused()
		if client.focus == nil then
			rect.visible(false)
			rect:geometry(to_rect_geometry({
				x = s.geometry.width / 2,
				y = s.geometry.height / 2,
				width = 1,
				height = 1,
			}))
		end
	end)
)

return {
	disable = function()
		rect.disabled = true
	end,
	enable = function()
		rect.disabled = false
	end,
}
