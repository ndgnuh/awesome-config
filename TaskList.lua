-- @TODO:
-- [done] hover on button show thumbnail, ~~with delay of 500ms~~
-- resize the thumbnail to the client size
local awful = re"awful"
local wibox = re"wibox"
local gears = re"gears"
local shape = re"gears.shape"
local beautiful = re"beautiful"
local ClientThumbnail = re"ClientThumbnail"

local arrowSize = 8
local infobubble = function(cr, w, h)
	local hh = h / 2
	cr:move_to(0, hh)
	cr:line_to(arrowSize, hh + arrowSize)
	cr:line_to(arrowSize, h)
	cr:line_to(w, h)
	cr:line_to(w, 0)
	cr:line_to(arrowSize, 0)
	cr:line_to(arrowSize, hh - arrowSize)
	cr:line_to(0, hh)
	cr:close_path()
end
local thumbnail = awful.popup{
	widget = wibox.widget{
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		{
			widget = wibox.container.place,
			id = 'thumb_container',
			forced_width = 192 * 2,
			{
				widget = ClientThumbnail,
				id = 'thumb'
			}
		},
	}
}

local thumb = thumbnail.widget:get_children_by_id('thumb')[1]
local thumbContainer = thumbnail.widget:get_children_by_id('thumb_container')[1]
local showThumbnail = function(widget, c)
	local geo = c:geometry()
	local scale = geo.width / geo.height
	thumbContainer.forced_height = thumbContainer.forced_width / scale

	thumb:set_client(c)
	thumbnail.ontop = true
	thumbnail.visible = true
	thumbnail:move_next_to(mouse.current_widget_geometry)
	thumbnail.x = thumbnail.x + arrowSize
end
local hideThumbnail = function(widget, c)
	thumbnail.ontop = false
	thumbnail.visible = false
end

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

		-- activate timer on enter
		self:connect_signal("mouse::enter", function()
			showThumbnail(self, c)
		end)

		-- hide thumbnail
		self:connect_signal("mouse::leave", function()
			hideThumbnail(self)
		end)
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
