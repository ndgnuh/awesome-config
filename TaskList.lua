-- @TODO:
-- hover on button show thumbnail, with delay of 500ms
local awful = re"awful"
local wibox = re"wibox"
local gears = re"gears"
local beautiful = re"beautiful"

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", {raise = true})
		end
	end),
	awful.button({ }, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
	end))

local layout = {
	layout = wibox.layout.fixed.vertical,
	spacing = beautiful.border_width,
}

local template = {
	widget = wibox.layout.align.horizontal,
	{
		wibox.widget.base.make_widget(),
		widget = wibox.container.background,
		forced_width = dpi(2),
		id = 'background_role',
	},
	{
		widget = wibox.container.margin,
		margins = beautiful.tasklist_icon_margin,
		{
			widget = awful.widget.clienticon,
			id = 'clienticon',
		},
	},
	nil,
	create_callback = function(self, c, index, objects) --luacheck: no unused args
		self:get_children_by_id('clienticon')[1].client = c
	end,
}

local tasklist = function(s)
	return awful.widget.tasklist{
		screen = s,
		widget_template = template,
		source = awful.widget.tasklist.source.all_clients,
		filter = awful.widget.tasklist.filter.allscreen,
		buttons = tasklist_buttons,
		layout = layout,
	}
end

return tasklist
