local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local widget = wibox.widget
local layout = wibox.layout
local container = wibox.container
local shape = gears.shape
local unpack = unpack or table.unpack
local root = _G.root
local awesome = _G.awesome
local client = _G.client
local myown = require("myown")

local wavy_cutout = 48
local base = beautiful.wibar_bg or beautiful.bg_normal
local spacing =beautiful.useless_gap

local function wavy_shape(cr, w, h, s)
	if type(cr) == "number" then
		return function(cr2, w, h)
			wavy_shape(cr2, w, h, cr)
		end
	end
	local s = wavy_cutout

	cr:move_to(0, 0)
	cr:line_to(w, 0)
	cr:line_to(w, h-s)
	cr:curve_to(-0.5*w, h-s+s/3, w * 1.5, h-s+s/3*2, 0, h)
	cr:close_path()
end

local function wavy_shape_cont(cr, w, h, s)
	if type(cr) == "number" then
		return function(cr2, w, h)
			wavy_shape(cr2, w, h, cr)
		end
	end
	local s = wavy_cutout

	cr:move_to(w, 0)
	cr:curve_to(-0.5*w, s/3, w*1.5, 2*s/3, 0, s)
	cr:line_to(0, h)
	cr:curve_to(w * 1.5, h-s+s/3*2, -0.5*w, h-s+s/3, w, h-s)
	-- cr:move_to(0, s)
	-- cr:curve_to(1.5*w, 2*s/3, -0.5*w, s/3, w, 0)
	-- cr:line_to(w, 0)
	-- cr:line_to(w, h-s)
	-- cr:curve_to(-0.5*w, h-s/3, w * 1.5, h-s/3*2, 0, h)
	cr:close_path()
end


local taglist = function(s)
	local w = awful.widget.taglist{
		filter  = awful.widget.taglist.filter.all,
		screen = s,
		layout = {
			layout = layout.flex.vertical,
		},
		style = {
			shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 5) end
		},
		widget_template = {
			widget = container.margin,
			margins = 3,
			{
				widget = container.background,
				shape = shape.squircle,
				id = "background_role",
				{
					widget = container.margin,
					left = 2,
					right = 2,
					top = 5,
					bottom = 5,
					{
						widget = layout.fixed.vertical,
						spacing = spacing,
						{
							widget = container.margin,
							margins = 2,
							id = "text_role_container",
							{
								widget = container.place,
								{
									widget = widget.textbox,
									id = "text_role",
								}
							},
						},
						{
							widget = layout.stack,
							id = "tasklist"
						},
					},
				}
			},
			create_callback = function(self, tag, index, tags)
				local unpack = unpack or table.unpack

				-- tasklist is dedicated to single tag
				do
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
					local tasklist = awful.widget.tasklist {
						screen = s,
						filter = function(c)
							return c.first_tag == tag
						end,
						layout = {
							layout = layout.fixed.vertical,
							spacing = spacing
						},
						buttons = buttons,
					}
					local t = self:get_children_by_id("tasklist")[1]
					t:reset()
					t:add(tasklist)
				end

				-- add tag buttons to the number only
				do
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
					-- use the padded box for clickability
					local w = self:get_children_by_id("text_role_container")[1]
					w:buttons(gears.table.join(unpack(tag_buttons)))
				end
			end,
		},
	}
	return w
end


awful.screen.connect_for_each_screen(function(s)
	s.bar = awful.wibar{
		position = "left",
		screen = s,
	}

	s.layoutbox = awful.widget.layoutbox(s)
	s.taglist = taglist(s)

	s.bar:setup{
		widget = layout.align.vertical,
		{
			widget = layout.fixed.vertical,
			{
				widget = container.margin,
				margins = 3,
				{
					widget = container.background,
					shape = shape.squircle,
					bg = beautiful.layoutbox_bg,
					{
						widget = container.margin,
						margins = 2,
						s.layoutbox,
					}
				},
			},
		},
		-- middle
		s.taglist,
		{
			layout = layout.fixed.vertical,
			-- systray
			{
				widget = container.margin,
				margins = 2,
				{
					widget = container.background,
					shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 5) end,
					bg = beautiful.bg_systray,
					{
						widget = container.margin,
						top = 5,
						bottom = 5,
						{
							widget = container.rotate,
							widget.systray(),
							direction = "west"
						}
					}
				}
			},
			-- clock
			{
				widget = container.place,
				{
					widget = widget.textclock,
					format = "<span color='#FFF'><b>%H\n%M</b></span>",
					font = "monospace 14",
					buttons = awful.button({}, 1, function()
						awful.spawn("gsimplecal", false)
					end)
				},
			},
		}
	}

end)
