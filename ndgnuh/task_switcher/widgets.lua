local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local popup_registry = require("lib.popup_registry")
local overdrip = require("lib.overdrip")
local allclients = require("providers.clients")
local state = require.rel("state")

local m = {}

m.get_popup = popup_registry()

m.preview_widget = overdrip.consumer_widget(function(ref)
	local c = ref:watch(state.selected_client_provider)
	if c and c.content then
		local surface = gears.surface(c.content)
		return wibox.widget({
			widget = wibox.widget.imagebox,
			image = surface,
		})
	else
		return wibox.widget({
			widget = wibox.widget.imagebox,
			text = "No preview",
		})
	end
end)

m.counter_widget = overdrip.consumer_widget(function(ref)
	local i = ref:watch(state.selection_index_provider)
	local clients = ref:watch(allclients.clients_provider)
	local n = #clients
	return wibox.widget.textbox("[" .. tostring(i) .. "/" .. tostring(n) .. "]")
end)

m.name_widget = overdrip.consumer_widget(function(ref)
	local c = ref:watch(state.selected_client_provider)
	local title
	if c then
		title = tostring(c.name) or "<Untitled client>"
	else
		title = "Invalid client"
	end
	return wibox.widget.textbox(title)
end)

---Get the popup for a screen, with the switcher widgets set up.
function m.build_popup(s)
	local popup = m.get_popup(s)
	popup.border_color = beautiful.primary
	popup.border_width = 10
	popup.opacity = 0.9
	popup.shadow = {
		radius = 10,
		opacity = 0.6,
		color = "#222222",
	}
	local width = 1280
	local spacing = 10

	popup:setup({
		widget = wibox.layout.fixed.vertical,
		spacing = spacing,
		{
			widget = wibox.container.place,
			forced_width = width,
			forced_height = width * 9 / 16,
			m.preview_widget,
		},
		{
			widget = wibox.container.constraint,
			width = width,
			{
				widget = wibox.container.margin,
				margins = spacing * 2,
				{
					widget = wibox.layout.fixed.horizontal,
					spacing = spacing,
					m.counter_widget,
					m.name_widget,
				},
			},
		},
	})
	return popup
end

return m
