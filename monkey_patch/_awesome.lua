---Connect to a signal module, like client.connect_signal
---Returns the destructor function.
---@param m table The module to connect signal
---@param signal string The signal's name
---@param callback function The signal's callback
---@return function destructor The function to disconnect signal
function awesome.module_connect_signal(m, signal, callback)
	m.connect_signal(signal, callback)

	return function()
		m.disconnect_signal(signal, callback)
	end
end

---Connect to a signal module, like c:connect_signal()
---Returns the destructor function.
---@param o table The object to connect signal
---@param signal string The signal's name
---@param callback function The signal's callback
---@return function destructor The function to disconnect signal
function awesome.object_connect_signal(obj, signal, callback)
	obj:connect_signal(signal, callback)

	return function()
		obj.disconnect_signal(signal, callback)
	end
end
