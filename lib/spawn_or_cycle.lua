local gears = require("gears")
local awful = require("awful")
local capi = {
	awesome = awesome,
	tag = tag,
	client = client,
	root = root,
	screen = screen,
}
local ic = require("lib.icecream")

local spawn_or_cycle = {
	--- State: list of clients
	clients = {},
}

function spawn_or_cycle:run()
	--- No matching client, spawn new one
	local all_clients = awful.client.all_clients(self.matcher)
	if #all_clients == 0 then
		awful.spawn.with_shell(self.command)
		return
	end

	--- Choose the target client, in case the
	--- currently client is not in the group
	local target_client = self.previous_client
	if not target_client or not target_client.valid then
		self.previous_client = nil
		target_client = all_clients[1]
	end

	--- If the focused client is not in the group
	--- focus on the resume-target-client
	local c = capi.client.focus
	local i = table.index_of(all_clients, c)
	if not c or not i then
		awful.client.focus_globally(target_client)
		return
	end

	--- Otherwise, focus the next client
	local j = table.cycle_index(all_clients, i)
	awful.client.focus_globally(all_clients[j])
end

function spawn_or_cycle:update_unfocus(c)
	--- Invalid client, ignore
	if not c.valid then
		return
	end

	--- If the client is still managed,
	--- mark it as the "resume point"
	local clients = awful.client.all_clients(self.matcher)
	local idx = table.index_of(clients, c)
	if idx then
		self.previous_client = c
	end
end

function spawn_or_cycle.new(args)
	local command = args.command
	local class = args.matcher or args.class or command
	local class_type = type(class)
	local spawn_callback = args.spawn_callback or nil

	local matcher
	--- If class is a string, match the exact class
	if class_type == "string" then
		matcher = function(c)
			if c.class == class then
				return true
			else
				return false
			end
		end
	--- If class is a table, match the exact class
	elseif class_type == "table" then
		matcher = function(c)
			for _, class_ in ipairs(class) do
				if c.class == class_ then
					return true
				end
			end
			return false
		end
	--- If class is a function, it is a matcher
	elseif class_type == "function" then
		matcher = class
	end

	local function matcher_wrapper(c)
		if not c or not c.valid then
			return false
		end

		return matcher(c)
	end

	-- Returning object
	local ret = {
		command = command,
		class = class,
		matcher = matcher_wrapper,
		spawn_callback = spawn_callback,
	}
	gears.table.crush(ret, spawn_or_cycle, true)

	capi.client.connect_signal("unfocus", function(c)
		ret:update_unfocus(c)
	end)

	return setmetatable(ret, {
		__call = function(self)
			self:run()
		end,
	})
end

return setmetatable(spawn_or_cycle, {
	__call = function(_, args)
		return spawn_or_cycle.new(args)
	end,
})
