local registry_mt = {}
registry_mt.__index = registry_mt

function registry_mt:__call(s)
	local widget = self.widget_for_screen[s]
	if not widget then
		widget = self.builder(s)
		self.widget_for_screen[s] = widget
	end
	return widget
end

function registry_mt:destroy()
	screen.disconnect_signal("removed", self._on_screen_removed)
	self.widget_for_screen = nil
end

return function(builder)
	local self = setmetatable({
		builder = builder,
		widget_for_screen = setmetatable({}, { __mode = "k" }),
	}, registry_mt)

	self._on_screen_removed = function(s)
		self.widget_for_screen[s] = nil
	end
	screen.connect_signal("removed", self._on_screen_removed)

	return self
end
