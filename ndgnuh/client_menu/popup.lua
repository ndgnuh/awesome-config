local property_popup -- late binding
local input_mode_popup -- late binding

local wibox = require("wibox")
local awful = require("awful")

local m = {}

function m.show(popup)
	popup.visible = true
end

function m.hide(popup)
	popup.visible = false
end

local function create_popup()
	local p = awful.popup({
		screen = screen.primary,
		placement = awful.placement.centered,
		widget = wibox.widget.textbox(""),
		ontop = true,
		visible = false,
		animation = {
			visible = {
				duration = 0.2,
				enter = { "fade", "slide_left" },
				exit = { "fade", "slide_right" },
			},
		},
	})

	return p
end

m.get_property_popup = function()
	if not property_popup then
		property_popup = create_popup()
	end

	return property_popup
end

m.get_input_mode_popup = function()
	if not input_mode_popup then
		input_mode_popup = create_popup()
	end

	return input_mode_popup
end

return m
