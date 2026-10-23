local naughty = require("naughty")
local capi = { client = client }
local ic = require("lib.icecream")

-- create a linked list of clients
-- connect and manage signals so that the focused client
-- is always ontop, basically a stack
local client_lists = {}

-- Remove closed client out of the list
local function remove_stale_clients()
	for i, c in ipairs(client_lists) do
		if not c or not c.valid then
			table.remove_at(client_lists, i)
		end
	end
end

capi.client.connect_signal("unmanaged", remove_stale_clients)
capi.client.connect_signal("untagged", remove_stale_clients)

-- Add client in to the list, or push it to top if it is already there
local function push_client(c)
	local i = table.index_of(client_lists, c)
	if i then
		table.remove_at(client_lists, i)
	end
	table.insert(client_lists, c)
end

capi.client.connect_signal("focus", push_client)

--- For debugging only
function client_lists:dump()
	local args = {}
	self:foreach(function(c)
		table.insert(args, tostring(c))
	end)
	ic(args)
end

-- when a client created or focused
local function switch()
	-- get next to last node
	-- which is the last focused client
	local n = #client_lists
	if n < 2 then
		naughty.notify({ title = "There is no previous client to switch to!" })
		return
	end

	-- empty list
	local c = client_lists[#client_lists - 1]
	if c and c.valid then
		c.first_tag:view_only()
		c.minimized = false
		c:activate({ raise = true, context = "key.history_focus" })
	end
end

return switch
