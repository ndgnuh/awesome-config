local rubato = require("lib.rubato")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local animation = gears.cache(function(ref)
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

-- buttons
local taglist_buttons = gears.table.join(
awful.button({}, 1, function(t)
	t:view_only()
end),
awful.button({ modkey }, 1, function(t)
	if client.focus then
		client.focus:move_to_tag(t)
	end
end),
awful.button({}, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end),
awful.button({}, 4, function(t)
	awful.tag.viewnext(t.screen)
end),
awful.button({}, 5, function(t)
	awful.tag.viewprev(t.screen)
end)
)

-- prevent the animation getting cleaning by GC
animation._cache = setmetatable(animation._cache, nil)

local function update_callback(ref, taglist, tag, idx, all)
	local timed = animation:get(ref)
	if tag.selected then
		timed.target = (idx - 1) * beautiful.wibar_width
	end
end

local function create_callback(ref, taglist, tag, idx, all)
	update_callback(ref, taglist, tag, idx, all)
end

local function setup(s, orient)
	local spacing = 5
	local ref = { orient = orient, screen = s, previous_idx = 1 }
	ref.taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = {
			bg = gears.color.transparent,
		},
		layout = {
			layout = wibox.layout.fixed[orient],
		},
		widget_template = {
			widget = wibox.container.place,
			forced_width = beautiful.wibar_height,
			{
				forced_width = beautiful.wibar_width,
				forced_height = beautiful.wibar_width,
				id = "text_role",
				widget = wibox.widget.textbox,
				align = "center",
				font = "monospace",
			},
			create_callback = function(...)
				create_callback(ref, ...)
			end,
			update_callback = function(...)
				update_callback(ref, ...)
			end,
		},
	})

	ref.background = wibox.widget({
		bg = beautiful.taglist_bg_normal,
		widget = wibox.container.background,
		wibox.widget.textbox(""),
	})
	ref.active_background = wibox.widget({
		widget = wibox.layout.manual,
		forced_width = beautiful.wibar_width,
		forced_height = beautiful.wibar_width,
		{
			point = { x = 0, y = 0 },
			forced_width = beautiful.wibar_width,
			forced_height = beautiful.wibar_width,
			bg = beautiful.taglist_bg_focus,
			widget = wibox.container.background,
			wibox.widget.textbox(""),
		},
	})

	local widget = wibox.widget({
		widget = wibox.layout.stack,
		ref.background,
		ref.active_background,
		ref.taglist,
	})

	return widget
end

return {
	setup = setup,
}
