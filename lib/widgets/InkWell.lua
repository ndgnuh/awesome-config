local wibox = require("wibox")
local gears = require("gears")

local InkWell = {}

function InkWell:set_hover_bg(color)
	self._private.hover_bg = color
end

function InkWell:set_normal_bg(color)
	self._private.normal_bg = color
	self:set_bg(color)
end

function InkWell:set_active_color(color)
	self._private.active_color = color
end

function InkWell:set_active(active)
	self._private.active = active
	if active then
		self.shape_border_color = self._private.active_color
		self.shape_border_width = 2
		self.shape = gears.shape.rounded_rect
	else
		self.border_width = 0
	end
end

function InkWell.new()
	local proxy = wibox.container.background()
	local ret = wibox.widget.base.make_widget(proxy, "wibox.widget.inkwell", { enable_properties = true })
	gears.table.crush(ret, wibox.container.background, true)
	gears.table.crush(ret, InkWell, true)

	-- ret:set_normal_bg("#232429")
	ret:set_hover_bg("#1d1f21")
	ret:set_active_color("#f0c674")
	ret._private.hover = false
	ret._private.press = false

	ret:connect_signal("mouse::enter", function(self)
		ret.bg = self._private.hover_bg
		ret._private.hover = true
	end)

	ret:connect_signal("button::press", function(self)
		self._private.press = true
		ret.bg = self._private.active_bg
	end)

	ret:connect_signal("button::release", function(self)
		self._private.press = false
		if ret._private.hover then
			ret.bg = self._private.hover_bg
		else
			ret.bg = self._private.normal_bg
		end
	end)

	ret:connect_signal("mouse::leave", function(self)
		ret._private.hover = false
		ret._private.press = false
		ret.bg = self._private.normal_bg
	end)

	return ret
end

wibox.widget.inkwell = InkWell

return setmetatable(InkWell, {
	__call = function()
		return InkWell.new()
	end,
})
