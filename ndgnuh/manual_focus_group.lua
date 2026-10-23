local gears = require("gears")
local naughty = require("naughty")

local ic = require("lib.icecream")
local libclient = require("lib.client")

local m = { previous_index = nil }

---Notification to show marked/unmarked
local notification

--- List of clients to focus to
local clients = {}
client.connect_signal("unmanage", function(c)
	local i = table.index_of(clients, c)
	if i then
		table.remove_at(clients, i)
	end
end)

function m.get_marked_clients()
	return clients
end

function m.notify(message)
	if notification then
		notification:destroy(naughty.notification_closed_reason.dismissed_by_command)
	end
	notification = naughty.notification({
		title = "Manual focus group",
		message = message,
	})
end

function m.unmark(c)
	c = c or client.focus

	if c then
		local idx = table.index_of(clients, c)
		if idx then
			table.remove_at(clients, idx)
		end
	end
end

function m.focus(c)
	local n = #clients
	if n == 0 then
		return
	end

	-- Find the next client index
	-- If the current client is in the group, cycle
	-- Otherwise, use the previous index
	c = c or client.focus
	local i = table.index_of(clients, c)
	local j
	if i then
		j = table.cycle_index(clients, i)
	else
		j = m.previous_index or 1
	end

	local next_client = clients[j]

	if next_client then
		gears.timer.delayed_call(function()
			libclient.focus_globally(next_client)
		end)
	end
end

function m.toggle_mark(c)
	local i = table.index_of(clients, c)
	if i then
		m.unmark(c)
		m.notify("Client unmarked")
	else
		m.mark(c)
		m.notify("Client marked")
	end
end

function m.mark(c)
	c = c or client.focus
	if not table.index_of(clients, c) then
		table.insert(clients, c)
	end
end

client.connect_signal("unfocus", function(c)
	local i = table.index_of(clients, c)
	if i then
		m.previous_index = i
	end
end)

return m
