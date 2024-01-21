local gobject = require("gears.object")
local gtimer = require("gears.timer")

local state = gobject({
	seconds_left = 0,
	is_active = false,
	is_panel_active = false,
})

function state.bind_widget(self, w)
	self:connect_signal("widget::redraw_needed", function()
		w:emit_signal("widget::redraw_needed")
	end)
end

function state.redraw(self)
	self:emit_signal("widget::redraw_needed")
end

function state.stop(self)
	self.seconds_left = 0
	self.is_active = 0
end

function state.set(self, time)
	self.seconds_left = time
	self.is_active = true
end

for _, k in ipairs({"seconds_left", "is_active", "is_panel_active"}) do
	state:connect_signal("property::" .. k, function(self)
		self:emit_signal("widget::redraw_needed")
	end)
end
return state
