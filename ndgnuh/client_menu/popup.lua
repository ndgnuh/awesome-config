local property_popup -- late binding
local input_popup -- late binding

local wibox = require("wibox")
local awful = require("awful")

local m = {}

function m.show(popup)
	popup.visible = true
end

function m.hide(popup)
	popup.visible = true
end

local function create_popup()
	return awful.popup({
		screen = screen.primary,
		animation = {
			duration = 0.2,
			enter = "slide-left",
			exit = "slide-right",
		},
		placement = awful.placement.centered,
		widget = wibox.widget.textbox(""),
		ontop = true,
	})
end

m.get_property_popup = function()
	if not property_popup then
		property_popup = create_popup()
	end

	return property_popup
end

m.get_input_popup = function()
	if not input_popup then
		input_popup = create_popup()
	end

	return input_popup
end

return m
