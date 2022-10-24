local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

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

local function setup (s)
	local margin = beautiful.font_size_px / 4
	local mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			id = "background_role",
			forced_width = math.min(s.geometry.width / 4, 400),
			widget = wibox.container.background,
			{
				widget = wibox.container.margin,
				margins = margin,
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
			create_callback = function(self, c)
				local icon = self:get_children_by_id("icon")[1]
				icon:set_client(c)
			end,
		},
	})
	return mytasklist
end

return {
	setup = setup
}
