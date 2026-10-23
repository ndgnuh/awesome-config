---Abstract away the process to make popup for each screen,
---which is often used.
local awful = require("awful")
local wibox = require("wibox")

return function(args)
	args = args or {}
	local placement = args.placement or awful.placement.centered
	local init_widget = args.intial_widget or wibox.widget.textbox("")
	local ontop = args.ontop or true

	-- Initialize a registry
	-- It is a weak table that is garbage collected when entry key is removed
	local popup_for_screen = setmetatable({}, { __mode = "k" })

	-- Remove popup when screen is removed
	screen.connect_signal("removed", function(s)
		popup_for_screen[s] = nil
	end)

	-- Idempotent function to initialize or get the screen
	return function(s)
		local popup = popup_for_screen[s]
		if popup == nil then
			popup = awful.popup({
				ontop = ontop,
				placement = placement,
				widget = type(init_widget) == "function" and init_widget(s) or init_widget,
			})
			popup_for_screen[s] = popup
		end

		return popup
	end
end
