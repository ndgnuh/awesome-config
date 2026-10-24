---This is a library to watch for all  the clients
---AwesomeWM has something similar (client.get) but they get the clients
---that are not managed too.
local overdrip = require("lib.overdrip")
local gears = require("gears")
-- local ic = require("lib.icecream")

local m = {}
local clients = {}

m.clients_provider = overdrip.provider(clients)
m.provider = m.clients_provider

client.connect_signal("request::manage", function(c)
	table.insert(clients, c)
	gears.timer.delayed_call(function()
		m.provider:notify_all() -- trigger rebuild
	end)
end)

client.connect_signal("request::unmanage", function(c)
	local idx = table.index_of(clients, c)

	if idx then
		table.remove_at(clients, idx)
	end
	gears.timer.delayed_call(function()
		m.provider:notify_all() -- trigger rebuild
	end)
end)

m.focused_provider = overdrip.provider(function()
	return client.focus
end)

local function update_focused()
	m.focused_provider.state = client.focus
end
client.connect_signal("focus", update_focused)
client.connect_signal("unfocus", update_focused)

function m.get()
	return m.clients_provider.state
end

return m
