local awful = require("awful")
local gears = require("gears")
local m = {}
local ic = require("lib.icecream")
local capi = {
	awesome = awesome,
	tag = tag,
	client = client,
	root = root,
	screen = screen,
}

m.force_normalize = function(c)
	gears.timer.delayed_call(function()
		c.floating = true
		gears.timer.delayed_call(function()
			m.normalize(c)
		end)
	end)
end

m.normalize = function(c)
	c.floating = false
	c.fullscreen = false
	c.maximized = false
	c.maximized_vertical = false
	c.maximized_horizontal = false
end

m.move_to_volatile = function(c, layout)
	layout = layout or awful.layout.layouts[1]
	local tagname = c.class or c.name or tostring(c)
	local t = awful.tag.add(tagname, {
		screen = c.screen,
		layout = layout,
		volatile = true,
	})

	c:tags({ t })
	t:view_only()
end

m.global_focus = function(c)
	if c and c.valid then
		c.first_tag:view_only()
		c.minimized = false
		capi.client.focus = c
		c:raise()
	end
end

m._move_to_delta_tag = function(c, delta)
	local s = c.screen
	local t = c.first_tag

	-- no tag? what do you want me to do?
	if not t then
		c:move_to_tag(s.first_tag)
		return
	end

	local tags = s.tags
	local i = t.index + delta
	if i <= 0 then
		i = #tags
	elseif i > #tags then
		i = 1
	end
	c:move_to_tag(tags[i])
	tags[i]:view_only()
end

m.move_to_next_tag = function(c)
	m._move_to_delta_tag(c, 1)
end

m.move_to_previous_tag = function(c)
	m._move_to_delta_tag(c, -1)
end

return m
