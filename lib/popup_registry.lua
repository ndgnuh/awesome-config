local awful = require("awful")
local wibox = require("wibox")

local function create_popup(s)
	return awful.popup({
		screen = s,
		ontop = true,
		placement = awful.placement.centered,
		widget = wibox.widget.textbox(""),
	})
end

local registry_mt = {}
registry_mt.__index = registry_mt

function registry_mt:__call(s)
	local popup = self.popup_for_screen[s]
	if not popup then
		popup = create_popup(s)
		self.popup_for_screen[s] = popup
	end
	return popup
end

function registry_mt:destroy()
	screen.disconnect_signal("removed", self._on_screen_removed)
	self.popup_for_screen = {}
end

return function()
	local self = setmetatable({
		popup_for_screen = setmetatable({}, { __mode = "k" }),
	}, registry_mt)

	self._on_screen_removed = function(s)
		self.popup_for_screen[s] = nil
	end
	screen.connect_signal("removed", self._on_screen_removed)

	return self
end
