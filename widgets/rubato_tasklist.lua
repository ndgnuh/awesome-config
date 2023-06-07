local rubato = require("lib.rubato")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local throttle = require("lib.throttle")
local pill = require("widgets.pill_container")

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local animations = gears.cache(function(ref)
	local timed = rubato.timed({
		easing = rubato.quadratic,
		intro = 0.1,
		duration = 0.2,
		subscribed = function(pos)
			local bgc = ref.active_background
			if ref.orient == "horizontal" then
				bgc:move(1, { x = pos, y = 0 })
			else
				bgc:move(1, { x = 0, y = pos })
			end
		end,
	})
	return timed
end)

-- prevent the animation getting cleaning by GC
animations._cache = setmetatable(animations._cache, nil)

-- animate
local function animation_callback(ref, tasklist, c, idx, all)
	local timed = animations:get(ref)
	if client.focus == c then
		timed.target = (idx - 1) * ref.max_width
	end
end

local function setup(s)
	local max_width = 300
	local margin = beautiful.font_size_px / 4
	local ref = { max_width = max_width, orient = "horizontal" }
	ref.tasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		style = {
			bg = gears.color.transparent,
		},
		widget_template = {
			id = "root",
			widget = wibox.container.constraint,
			width = max_width,
			forced_width = max_width,
			{

				widget = wibox.container.margin,
				margins = 10,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = margin,
					{
						id = "icon",
						widget = awful.widget.clienticon,
					},
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
				},
			},
			create_callback = function(self, c, idx, all)
				local icon = self:get_children_by_id("icon")[1]
				icon:set_client(c)
				animation_callback(ref, self, c, idx, all)
			end,
			update_callback = function(self, c, idx, all)
				animation_callback(ref, self, c, idx, all)
			end,
		},
	})

	ref.background = wibox.widget({
		bg = beautiful.tasklist_bg_normal,
		widget = wibox.container.background,
		wibox.widget.textbox(""),
	})
	ref.active_background = wibox.widget({
		widget = wibox.layout.manual,
		{
			forced_width = max_width,
			forced_height = beautiful.wibar_width,
			point = { x = 0, y = 0 },
			bg = beautiful.tasklist_bg_focus,
			widget = pill,
			margins = beautiful.font_size_px / 4 * 1.3,
			wibox.widget.textbox(""),
		},
	})

	ref.widget = wibox.widget({
		widget = wibox.layout.stack,
		ref.background,
		ref.active_background,
		ref.tasklist,
	})

	local callback = function(...)
		local t = awful.tag.selected()
		if t then
			ref.widget.visible = (#t:clients()) > 0
			ref.active_background.visible = (#t:clients()) > 0
		end
	end
	callback = throttle.delayed(0.03, callback)

	s:connect_signal("tag::history::update", callback)
	client.connect_signal("focus", callback)
	client.connect_signal("unfocus", callback)

	return ref.widget
end

return {
	setup = setup,
}
