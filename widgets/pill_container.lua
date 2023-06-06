local wibox = require("wibox")
local widget = require("wibox.widget")
local container = require("wibox.container")
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local shape = require("gears.shape")
local beautiful = require("beautiful")

local pill = {mt = {}}

pill.children = wibox.widget{
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
				widget = wibox.layout.stack,
				id = 'content'
			}
		}
	}
}

function pill:get_child(id)
	return self.children:get_children_by_id(id)[1]
end

function pill:set_bg(bg)
	bg = bg or beautiful.pill_bg
	self:get_child('background'):set_bg(bg)
end

function pill:set_padding(padding)
	padding = padding or beautiful.pill_padding
	self:get_child('margin').margins = padding
	self:emit_signal("widget::redraw_needed")
	self:emit_signal("widget::layout_changed")
end

function pill:set_widget(widget)
    if widget then
        base.check_widget(widget)
    end
    self._private.widget = widget
    self:emit_signal("widget::layout_changed")
end

function pill:set_children(children)
	local content = self.children:get_children_by_id("content")[1]
	content:reset()
	content:add(children[1])
	self:emit_signal("widget::layout_changed")
end


-- wrapping function
function pill:draw(ctx, cr, width, height)
	self.children:draw(ctx, cr, width, height)
end

function pill:layout(_, width, height)
	return { base.place_widget_at(self.children, 0, 0, width, height) }
end

function pill:fit(ctx, width, height)
	return base.fit_widget(self, ctx, self.children, width, height)
end


local function new(widget, bg, padding)
	local ret = base.make_widget(nil, nil, {enable_properties = true})
	gtable.crush(ret, pill, true)
	ret:set_padding(padding)
	ret:set_bg(bg)
	return ret
end

function pill.mt:__call(...)
	return new(...)
end

return setmetatable(pill, pill.mt)
