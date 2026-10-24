---Signal helpers that return a disconnect function instead of
---forcing the caller to keep a reference to the handler.
local cm = ...
local m = require(cm .. "constants")

---Wrap a disconnect call so it only runs once
---@param disconnect function
---@return function
local function once(disconnect)
	local done = false
	return function()
		if done then
			return
		end
		done = true
		disconnect()
	end
end

---Connect to an object signal, e.g. `c:connect_signal(name, fn)`
---@param obj table The object (client, tag, screen, widget...)
---@param name string The signal name
---@param fn function The handler
---@return function disconnect
function m.connect(obj, name, fn)
	obj:connect_signal(name, fn)
	return once(function()
		obj:disconnect_signal(name, fn)
	end)
end

---Connect to a module/class signal, e.g. `client.connect_signal(name, fn)`
---@param module table The module (client, tag, screen, awesome...)
---@param name string The signal name
---@param fn function The handler
---@return function disconnect
function m.static_connect(module, name, fn)
	module.connect_signal(name, fn)
	return once(function()
		module.disconnect_signal(name, fn)
	end)
end

---Collect disconnect functions and drop them all at once
---Usage:
---  local g = signals.group()
---  g:add(signals.connect(c, "property::name", fn))
---  g:disconnect_all()
---@return table
function m.group()
	local g = { disconnects = {} }

	function g:add(disconnect)
		table.insert(self.disconnects, disconnect)
		return disconnect
	end

	function g:disconnect_all()
		for _, disconnect in ipairs(self.disconnects) do
			disconnect()
		end
		self.disconnects = {}
	end

	return g
end

return m
