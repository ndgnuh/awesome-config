local popup = require.rel("popup")
local consts = require.rel("consts")
local bamboo_menu = require.rel("bamboo_menu")
local wibox = require("wibox")
local awful = require("awful")

local widgets = require("lib.widgets")
local icons = require("assets.icons")

-- Local states
local m = {}
local property_grabber -- late binding for keygrabber
local property_client -- client captured when the menu is shown
local refresh -- late binding, rebuild the menu widgets

-- Toggleable client properties, in display order
local properties = {
	consts.OPTION_ONTOP,
	consts.OPTION_STICKY,
	consts.OPTION_FLOATING,
	consts.OPTION_MAXIMIZED,
	consts.OPTION_MINIMIZED,
	consts.OPTION_FULLSCREEN,
}

local properties_to_hotkeys = {
	[consts.OPTION_ONTOP] = "o",
	[consts.OPTION_STICKY] = "s",
	[consts.OPTION_FLOATING] = "t",
	[consts.OPTION_MAXIMIZED] = "m",
	[consts.OPTION_MINIMIZED] = "n",
	[consts.OPTION_FULLSCREEN] = "f",
}

local action_quit = function()
	if property_grabber then
		property_grabber:stop()
		property_grabber = nil
	end
	property_client = nil
	popup.hide(popup.get_property_popup())
end

-- Unlike bamboo menu, the menu stays after toggling
local action_toggle = function(property)
	return function()
		local c = property_client
		if not (c and c.valid) then
			return
		end
		c[property] = not c[property]
		refresh()
	end
end

local action_bamboo = function()
	action_quit()
	bamboo_menu.show()
end

local property_hotkeys = {
	["q"] = action_quit,
	["Escape"] = action_quit,
	["Return"] = action_quit,
	["space"] = action_quit,
	["b"] = action_bamboo,
}
for property, hotkey in pairs(properties_to_hotkeys) do
	property_hotkeys[hotkey] = action_toggle(property)
end

local function build_tile(icon, hotkey, title, action)
	local place = function(w, forced_width)
		return {
			widget = wibox.container.place,
			forced_height = 32,
			forced_width = forced_width,
			w,
		}
	end

	return {
		widget = widgets.InkWell,
		buttons = {
			awful.button({}, 1, action),
		},
		{
			widget = wibox.container.margin,
			margins = 8,
			{
				widget = wibox.layout.fixed.horizontal,
				spacing = 28,
				place(wibox.widget.textbox(hotkey:upper()), 32),
				place(wibox.widget.imagebox(icon), 32),
				place(wibox.widget.textbox(title)),
			},
		},
	}
end

local function build_property_tile(property, selected)
	local icon = selected and icons.checkbox_checked or icons.checkbox_unchecked
	return build_tile(
		icon,
		properties_to_hotkeys[property],
		consts.options_to_titles[property],
		action_toggle(property)
	)
end

local function build_property_widgets(c)
	local markup = c and c.valid and ("<b>" .. tostring(c.class) .. "</b>") or "(No focused window)"
	local layout = wibox.widget({
		layout = wibox.layout.fixed.vertical,
		{
			widget = wibox.container.margin,
			margins = 4,
			{
				widget = wibox.widget.textbox,
				markup = markup,
			},
		},
	})

	for _, property in ipairs(properties) do
		layout:add(build_property_tile(property, c and c.valid and c[property]))
	end
	layout:add(build_tile(icons.settings, "b", consts.options_to_titles[consts.OPTION_BAMBOO_INPUT], action_bamboo))
	layout:add(build_tile(icons.logout, "q", consts.options_to_titles[consts.OPTION_CANCEL], action_quit))

	return layout
end

refresh = function()
	popup.get_property_popup().widget = build_property_widgets(property_client)
end

m.show = function()
	-- Capture the client, toggling (e.g. minimized) may change focus
	property_client = client.focus
	local p = popup.get_property_popup()
	refresh()

	if property_grabber then
		property_grabber:stop()
	end
	property_grabber = awful.keygrabber({
		autostart = true,
		keypressed_callback = function(_, _, key)
			local action = property_hotkeys[key]
			if action then
				action()
			end
		end,
	})

	popup.show(p)
end

m.hide = action_quit

return m
