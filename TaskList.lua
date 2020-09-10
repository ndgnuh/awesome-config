-- @TODO:
-- [done] hover on button show thumbnail, ~~with delay of 500ms~~
-- [done] resize the thumbnail to the client size
local awful = re"awful"
local wibox = re"wibox"
local gears = re"gears"
local shape = re"gears.shape"
local beautiful = re"beautiful"
local ClientThumbnail = re"ClientThumbnail"
local icon = re"icon"

local thumbHeight = 248
local arrowSize = 12
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
	visible = false,
	shape = infobubble,
	widget = wibox.widget{
		widget = wibox.container.background,
		bg = beautiful.color11,
		{
			widget = wibox.container.margin,
			left = arrowSize + 4,
			right = 4,
			bottom = 4,
			top = 4,
			{
				forced_height = thumbHeight,
				forced_width = thumbHeight,
				widget = ClientThumbnail,
				id = 'thumb'
			}
		},
	}
}

local thumb = thumbnail.widget:get_children_by_id('thumb')[1]
local thumbContainer = thumbnail.widget:get_children_by_id('thumb_container')[1]
local showThumbnail = function(widget, c)
	thumb:set_client(c)
	local geo = c:geometry()
	local scale = thumb.forced_height / geo.height
	thumb.forced_width = geo.width * scale

	thumbnail.ontop = true
	thumbnail.visible = true
	thumbnail:move_next_to(mouse.current_widget_geometry)
	thumbnail.x = thumbnail.x + arrowSize
	thumbnail.y = thumbnail.y + (thumbHeight - beautiful.wibar_width / 2) * 0.5 
end
local hideThumbnail = function(widget, c)
	thumbnail.ontop = false
	thumbnail.visible = false
end

-- create client menu
-- with actions like kill and toggles
local clientmenu = function(c)
	awful.menu{
		items = {
			{
				"Close",
				function() c:kill() end,
				icon"close.svg",
			},
			{
				c.minimized and "Un-minimized" or "Minimize",
				function()
					c.minimized = not c.minimized
					if not c.minimized then
						c:raise()
					end
				end,
				icon"minimize.svg",
			},
			{
				c.maximized and "Un-maximize" or "Maximize",
				function() c.maximized = not c.maximized end,
				c.maximized and icon"maximized-inactive.svg" or icon"maximized-active.svg",
			},
			{
				c.floating and "Floating" or "Follow layout",
				function() c.floating = not c.floating end,
				c.floating and icon"floating-active.svg" or icon"floating-inactive.svg",
			},
			{
				"Fullscreen",
				function() c.fullscreen = not c.fullscreen end,
				icon"maximized-active.svg",
			},
			{
				"To next screen",
				function() c:move_to_screen() end
			},
			{ "Cancel", "" }
		}
	}:show()
end

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", {raise = true})
		end
	end),
	awful.button({ }, 3, clientmenu),
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
		widget = wibox.container.background,
		id = 'background_role_2',
		{
			widget = wibox.container.margin,
			margins = beautiful.wibar_width / 8,
			{
				widget = awful.widget.clienticon,
				id = 'clienticon',
			},
		}
	},
	nil,
	update_callback = function(self, c, index, objects) --luacheck: no unused args
		-- set second brightbackground
		local bg2 = gears.color.transparent
		if c == client.focus then
			bg2 = beautiful.color8
		end
		self:get_children_by_id('background_role_2')[1].bg = bg2
	end,
	create_callback = function(self, c, index, objects) --luacheck: no unused args
		self:get_children_by_id('clienticon')[1].client = c
		-- set second brightbackground
		local bg2 = gears.color.transparent
		if c == client.focus then
			bg2 = beautiful.color8
		end
		self:get_children_by_id('background_role_2')[1].bg = bg2

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
