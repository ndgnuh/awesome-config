local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local taglist = "normal_taglist"

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

local function setup(s, orient)
	local bw = beautiful.wibar_width
	local spacing = 5
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout = {
			layout = wibox.layout.fixed[orient],
		},
		widget_template = {
			widget = wibox.container.place,
			forced_width = beautiful.wibar_height,
			{
				id = "background_role",
				forced_width = beautiful.wibar_width,
				forced_height = beautiful.wibar_width,
				widget = wibox.container.background,
				{
					id = "text_role",
					forced_width = beautiful.wibar_height - spacing,
					widget = wibox.widget.textbox,
					align = "center",
					font = "monospace",
				},
			},
		},
	})
end

local function setup_vertical(s)
	return setup(s, "vertical")
end

local function setup_horizontal(s)
	return setup(s, "horizontal")
end
return {
	setup_horizontal = setup_horizontal,
	setup_vertical = setup_vertical,
	setup = setup,
}
