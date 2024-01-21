local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local widget = wibox.widget
local layout = wibox.layout
local container = wibox.container
local shape = gears.shape
local unpack = unpack or table.unpack
local client = _G.client
local mod = "Mod4"
require("awful.autofocus")

-- these create_ functions are callback for tag/tasklist
-- that's why they have unused arguments
-- it's more convenience to use `...` to pass all the stuff to them

local function create_clienticon(self, c, index, cs)
	local ci = self:get_children_by_id("client_icon")[1]
	ci.client = c
end

local function create_tasklist(self, tag, index, tags)
	local tl_container = self:get_children_by_id("tasklist")[1]

	local buttons = gears.table.join(unpack{
		awful.button({}, 1, function(c)
			if c == client.focus then
				c.minimized = true
			else
				c:emit_signal("request::activate", "tasklist", {raise = true})
				local t = c.first_tag
				t:view_only()
				client.focus = c
				c:raise()
			end
		end),
		awful.button({}, 3, function()
			awful.menu.client_list({theme = {width = 250}})
		end),
		awful.button({}, 4, function() awful.client.focus.byidx(1) end),
		awful.button({}, 5, function()
			awful.client.focus.byidx(-1)
		end)
	})
	local tl = awful.widget.tasklist{
		screen = self.screen,
		filter = function(c)
			return c.first_tag == tag
		end,
		buttons = buttons,
		style = {
			shape = shape.circle
		},
		layout = {
			layout = layout.fixed.vertical
		},
		widget_template = {
			widget = container.margin,
			margins = 2,
			{
				widget = container.background,
				id = "background_role",
				{
					widget = container.margin,
					margins = 4,
					{
						widget = awful.widget.clienticon,
						id = 'client_icon',
					},
				}
			},
			create_callback = function(...)
				create_clienticon(...)
			end,
			update_callback = function(...)
				create_clienticon(...)
			end
		}
	}
	tl_container:reset()
	tl_container:add(tl)
end

local function create_tagbuttons(self, tag, index, tags)
	local bg = self:get_children_by_id("background_role")[1]
	local tag_buttons = {
		awful.button({}, 3, function()
			awful.tag.viewtoggle(tag)
		end),
		awful.button({}, 1, function()
			if tag.selected then
				awful.tag.viewtoggle(tag)
			else
				tag:view_only()
			end
		end)
	}
	bg:buttons(gears.table.join(unpack(tag_buttons)))
end

local function create(s)
	return awful.widget.taglist{
		filter  = awful.widget.taglist.filter.all,
		screen = s,
		layout = {
			layout = layout.flex.vertical
		},
		style = {
			shape = shape.circle
		},
		widget_template = {
			widget = layout.fixed.vertical,
			spacing = 10,
			widget.textbox(),
			{
				widget = container.background,
				id = "background_role",
				{
					widget = container.margin,
					margins = 2,
					{
						widget = container.place,
						{
							widget = widget.textbox,
							id = "text_role",
						}
					},
				}
			},
			{
				widget = layout.fixed.vertical,
				id = 'tasklist'
			},
			create_callback = function(...)
				local self = select(1, ...)
				-- this is to pass the screen to tasklist
				-- since the callback didn't get the `s`
				self.screen = s
				create_tagbuttons(...)
				create_tasklist(...)
			end ,
		}
	}
end


return create
