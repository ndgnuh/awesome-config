local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

local libclient = require("lib.client")
local popup_maker = require("lib.popup_maker")
local notifier = require("lib.notifier_widget")
local overdrip = require("lib.overdrip")
local allclients = require("lib.allclients")

local m = {}
local ic = require("lib.icecream")

local get_popup = popup_maker()

local enabled_provider = overdrip.provider(false)
local selection_index_provider = overdrip.provider(1)
local selected_client_provider = overdrip.provider(function(ref)
	local i = ref.watch(selection_index_provider)
	local clients = ref.watch(allclients.provider)
	return clients[i]
end)

local preview_widget = overdrip.consumer_widget(function(ref)
	local c = ref.watch(selected_client_provider)
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

local counter_widget = overdrip.consumer_widget(function(ref)
	-- local enabled = ref.watch(enabled_provider)
	-- if not enabled then
	-- 	return dummy_widget
	-- end

	local i = ref.watch(selection_index_provider)
	local clients = ref.watch(allclients.provider)
	local n = #clients
	return wibox.widget.textbox("[" .. tostring(i) .. "/" .. tostring(n) .. "]")
end)

local name_widget = overdrip.consumer_widget(function(ref)
	local c = ref.watch(selected_client_provider)
	local title
	if c then
		title = tostring(c.name) or "<Untitled client>"
	else
		title = "Invalid client"
	end
	return wibox.widget.textbox(title)
end)

function m.select_delta(s, delta)
	s = s or awful.screen.focused()
	m.show(s)
	local i = selection_index_provider.state + delta
	local clients = allclients.get()
	if i > #clients then
		i = 1
	end
	if i < 1 then
		i = #clients
	end
	selection_index_provider.state = i
end

function m.select_previous(s)
	m.select_delta(s, -1)
end

function m.select_next(s)
	m.select_delta(s, 1)
end

function m.stop(s)
	local popup = get_popup(s)
	enabled_provider.state = false
	gears.timer.delayed_call(function()
		popup.visible = false

		local c = selected_client_provider.state
		if (not c) or (c and c == client.focus) then
			return
		else
			libclient.focus_globally(c)
		end
	end)
end

function m.show(s)
	-- Default screen
	s = s or awful.screen.focused()
	m.current_screen = s

	-- Mark enabled
	if enabled_provider.state then
		return
	end
	enabled_provider.state = true

	-- Keygrabber
	local grabber = awful.keygrabber({
		timeout_callback = function()
			m.stop(s)
		end,
		stop_callback = function()
			gears.timer.delayed_call(function()
				m.stop(s)
			end)
		end,
		stop_key = "Super_L",
		stop_event = "release",
		start_callback = function()
			local clients = allclients.get()
			local i = table.index_of(clients, client.focus)
			selection_index_provider.state = i or 1
		end,
		keypressed_callback = function(self, mod, key)
			if key == "Escape" then
				m.stop(s)
			elseif key == "j" then
				m.select_next(s)
			elseif key == "k" then
				m.select_previous(s)
			end
		end,
	})

	-- Get popup
	local popup = get_popup(s)
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
			preview_widget,
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
					counter_widget,
					name_widget,
				},
			},
		},
	})
	popup.visible = true
	grabber:start()
end

return m
