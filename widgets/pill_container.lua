local wibox = require("wibox")
local widget = require("wibox.widget")
local container = require("wibox.container")
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local shape = require("gears.shape")
local beautiful = require("beautiful")

local pill = {mt = {}}

local function wrapper()
	return wibox.widget{
		widget = wibox.container.margin,
		id = 'margin',
		{
			widget = wibox.container.background,
			shape = shape.rounded_rect,
			id = 'background',
			{
				widget = wibox.container.margin,
				left = 10,
				right = 10,
				{
					widget = wibox.layout.fixed.horizontal,
					spacing = 10,
					id = 'content'
				}
			}
		}
	}
end

function pill:child(id)
	return self.wrapper:get_children_by_id(id)[1]
end

function pill:set_margins(margins)
	margins = margins or beautiful.pill_bg or 0
	self:child('margin').margins = margins
	self:emit_signal("widget::redraw_needed")
end

function pill:set_spacing(spacing)
	self:child('content'):set_spacing(spacing)
	self:emit_signal("widget::layout_changed")
end

function pill:set_bg(bg)
	bg = bg or beautiful.pill_bg
	self:child('background'):set_bg(bg)
	self:emit_signal("widget::redraw_needed")
end

function pill:set_children(children)
	local content = self:child("content")
	local spacing = content.spacing
	content:reset()
	for _, child in ipairs(children) do
		content:add(child)
	end
	self:emit_signal("widget::layout_changed")
	self:emit_signal("widget::redraw_needed")
end

function pill:fit(context, width, height)
    return base.fit_widget(self, context, self.wrapper, width, height)
end

function pill:layout(_, width, height)
	return { base.place_widget_at(self.wrapper, 0, 0, width, height) }
end

local function new(widget, bg, margins)
	local ret = base.make_widget(nil, nil,  {enable_properties=true})
	ret.wrapper = wrapper()
	gtable.crush(ret, wibox.container.background, true)
	gtable.crush(ret, pill, true)
	return ret
end

function pill.mt:__call(...)
	return new(...)
end

return setmetatable(pill, pill.mt)
