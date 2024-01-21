local has_rubato, rubato = pcall(require, "lib.rubato")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local bar_names = { hbar = "hbar", vbar = "vbar" }
local hbar = "hbar"
local vbar = "vbar"
local geometry = "dualbar_geometry"

local function wrap_mask(widget)
	widget["id"] = "main"
	return {
		layout = wibox.layout.stack,
		widget,
		{
			id = "mask",
			visible = false,
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			opacity = 100,
			wibox.widget.textbox(" "),
		},
	}
end

local function setup_hbar(s, widget)
	s[hbar] = wibox({
		x = s.geometry.x,
		y = s.geometry.y,
		width = s.geometry.width,
		height = beautiful.wibar_height,
		screen = s,
		bg = beautiful.wibar_bg,
		visible = true,
	})

	s[hbar]:setup(wrap_mask(widget))
	s[hbar]:struts({ top = s[hbar].height })

	return s[hbar]
end

local function setup_vbar(s, widget)
	s[vbar] = wibox({
		screen = s,
		x = s.geometry.x,
		y = s.geometry.y + beautiful.wibar_height,
		width = beautiful.wibar_width,
		height = s.geometry.height - beautiful.wibar_height,
		visible = true,
	})

	s[vbar]:setup(wrap_mask(widget))

	s[vbar]:struts({ left = beautiful.wibar_width })
	return s
end

local animations = {}
local function toggle_rubato(s)
	local target = beautiful.wibar_width
	local vheight = s.geometry.height - beautiful.wibar_height * 2 - 1
	local timed = animations[s]
	if not timed then
		animations[s] = rubato.timed({
			intro = 0.1,
			duration = 0.2,
			pos = target,
			subscribed = function(pos, ...)
				pos = math.max(pos, 1)
				s[hbar]:geometry({ height = pos })
				s[vbar]:geometry({ width = pos, y = pos })
				s[hbar]:struts({ top = pos })
				s[vbar]:struts({ left = pos })
			end,
		})
		timed = animations[s]
	end
	local visible = timed.pos == target
	local hmask = s[hbar]:get_children_by_id("mask")[1]
	local vmask = s[vbar]:get_children_by_id("mask")[1]
	local hmain = s[hbar]:get_children_by_id("main")[1]
	local vmain = s[vbar]:get_children_by_id("main")[1]
	if visible then
		hmask.visible = true
		vmask.visible = true
		hmain.visible = false
		vmain.visible = false
		timed.target = 1
	else
		timed.target = target
		hmask.visible = false
		vmask.visible = false
		hmain.visible = true
		vmain.visible = true
	end
end

-- container
local dualbar = gears.cache(function(s)
	local ob = { [vbar] = s[vbar], [hbar] = s[hbar] }

	ob.get_geometry = function(self)
		return {
			v = self[vbar]:geometry(),
			h = self[hbar]:geometry(),
		}
	end

	ob.set_geometry = function(self, geos)
		self[vbar]:geometry(geos.v)
		self[hbar]:geometry(geos.h)
	end

	ob.geometry = function(self, geo)
		if geo then
			self:set_geometry(geo)
		else
			return self:get_geometry()
		end
	end

	return ob
end)

-- local function toggle_rubato(s)
-- 	db = dualbar(s)
-- end

local function toggle_norubato(s)
	s[vbar].visible = not s[vbar].visible
	s[hbar].visible = not s[hbar].visible
end

local function toggle(s)
	if has_rubato then
		toggle_rubato(s)
	else
		toggle_norubato(s)
	end
end

return {
	setup_hbar = setup_hbar,
	setup_vbar = setup_vbar,
	toggle = toggle,
}
