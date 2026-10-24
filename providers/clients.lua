---Providers for client related states.
---AwesomeWM has something similar (client.get) but they get the clients
---that are not managed too.
local overdrip = require("lib.overdrip")
local gears = require("gears")
local client = _G.client

local m = {}
local clients = {}

-- all managed clients
m.clients_provider = overdrip.provider(clients)

client.connect_signal("request::manage", function(c)
	table.insert(clients, c)
	gears.timer.delayed_call(function()
		m.clients_provider:notify_all() -- trigger rebuild
	end)
end)

client.connect_signal("request::unmanage", function(c)
	local idx = table.index_of(clients, c)

	if idx then
		table.remove_at(clients, idx)
	end
	gears.timer.delayed_call(function()
		m.clients_provider:notify_all() -- trigger rebuild
	end)
end)

-- focused client
m.focused_provider = overdrip.provider(function()
	return client.focus
end)

local function update_focused()
	m.focused_provider.state = client.focus
end
client.connect_signal("focus", update_focused)
client.connect_signal("unfocus", update_focused)

-- tiling (non-floating) clients
m.tiling_provider = overdrip.provider(function(ref)
	local ret = {}
	for _, c in ipairs(ref.watch(m.clients_provider)) do
		if c.valid and not c.floating then
			table.insert(ret, c)
		end
	end
	return ret
end)

client.connect_signal("property::floating", function()
	m.tiling_provider:recompute()
end)

-- focused client name
m.focused_name_provider = overdrip.provider(function(ref)
	local c = ref.watch(m.focused_provider)
	if c then
		return tostring(c.title or c.name or c.class or "Untitled window")
	end
	return nil
end)

local function refresh_name(c)
	if c == client.focus then
		m.focused_name_provider:recompute()
	end
end
client.connect_signal("property::name", refresh_name)
client.connect_signal("property::class", refresh_name)

-- focused client icon
m.focused_icon_provider = overdrip.provider(function(ref)
	local c = ref.watch(m.focused_provider)
	return c and c.icon
end)

client.connect_signal("property::icon", function(c)
	if c == client.focus then
		m.focused_icon_provider:recompute()
	end
end)

return m
