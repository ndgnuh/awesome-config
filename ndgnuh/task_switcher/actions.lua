local gears = require("gears")
local awful = require("awful")

local libclient = require("lib.client_api")
local allclients = require("providers.clients")
local state = require.rel("state")
local widgets = require.rel("widgets")

local m = {}

function m.select_delta(s, delta)
	s = s or awful.screen.focused()
	m.show(s)
	local i = state.selection_index_provider.state + delta
	local clients = allclients.get()
	if i > #clients then
		i = 1
	end
	if i < 1 then
		i = #clients
	end
	state.selection_index_provider:set(i)
end

function m.select_previous(s)
	m.select_delta(s, -1)
end

function m.select_next(s)
	m.select_delta(s, 1)
end

function m.stop(s)
	local popup = widgets.get_popup(s)
	state.enabled_provider:set(false)
	gears.timer.delayed_call(function()
		popup.visible = false

		local c = state.selected_client_provider.state
		if (not c) or (c and c == client.focus) then
			return
		else
			libclient.jumpto(c)
		end
	end)
end

function m.show(s)
	-- Default screen
	s = s or awful.screen.focused()

	-- Mark enabled
	if state.enabled_provider.state then
		return
	end
	state.enabled_provider:set(true)

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
			state.selection_index_provider:set(i or 1)
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

	local popup = widgets.build_popup(s)
	popup.visible = true
	grabber:start()
end

return m
