--- Async wrapper around `bamboo-cli`, the configuration tool for ibus-bamboo.
---
--- Usage:
---   local bamboo = require("lib.bamboo_cli")
---   bamboo.mode.get(function(mode) print(mode) end) -- e.g. "forward-key-1"
---   bamboo.mode.set_focused("preedit")
---   bamboo.mode.list(function(modes) print(modes[1].name) end)
---   bamboo.introspector.set_command("somewm-focused-wmclass")
---
--- Every callback is optional. Getters call back with the trimmed output, or
--- nil and the error output if the command failed. Setters call back with
--- true, or false and the error output.
local awful = require("awful")

local m = {
	mode = {},
	introspector = {},
}

--- Run `bamboo-cli args...`, call back with (stdout, stderr, exit_code)
local function run(args, callback)
	local cmd = { "bamboo-cli" }
	for _, arg in ipairs(args) do
		table.insert(cmd, tostring(arg))
	end
	awful.spawn.easy_async(cmd, function(stdout, stderr, _, exit_code)
		if callback then
			callback(stdout, stderr, exit_code)
		end
	end)
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Call back with the trimmed stdout as a single value
local function getter(args)
	return function(callback)
		run(args, function(stdout, stderr, exit_code)
			if not callback then
				return
			end
			if exit_code ~= 0 then
				callback(nil, trim(stderr .. stdout))
			else
				callback(trim(stdout))
			end
		end)
	end
end

--- Call back with whether the command succeeded
local function setter(args)
	return function(...)
		local values = { ... }
		local n = select("#", ...)
		local callback = type(values[n]) == "function" and table.remove(values, n) or nil
		local full = {}
		for _, arg in ipairs(args) do
			table.insert(full, arg)
		end
		for _, value in ipairs(values) do
			table.insert(full, value)
		end
		run(full, function(stdout, stderr, exit_code)
			if callback then
				if exit_code ~= 0 then
					callback(false, trim(stderr .. stdout))
				else
					callback(true)
				end
			end
		end)
	end
end

--- Typing modes

---@class BambooMode
---@field index integer
---@field name string
---@field display_name string

--- List typing modes, call back with a list of `BambooMode`
function m.mode.list(callback)
	run({ "mode", "list" }, function(stdout, stderr, exit_code)
		if not callback then
			return
		end
		if exit_code ~= 0 then
			callback(nil, trim(stderr .. stdout))
			return
		end
		local modes = {}
		for line in stdout:gmatch("[^\n]+") do
			local index, name, display_name = line:match("^%s*(%d+)%s+(%S+)%s+(.-)%s*$")
			if index then
				table.insert(modes, {
					index = tonumber(index),
					name = name,
					display_name = display_name,
				})
			end
		end
		callback(modes)
	end)
end

--- Current typing mode for the focused client
m.mode.get = getter({ "mode", "get" })
m.mode.get_default = getter({ "mode", "get-default" })
--- set_default(mode[, callback]), mode is an index or a short name
m.mode.set_default = setter({ "mode", "set-default" })
--- set(app_id, mode[, callback]), app_id is a wayland app id or a X11 wm_class
m.mode.set = setter({ "mode", "set" })
--- set_focused(mode[, callback])
m.mode.set_focused = setter({ "mode", "set", "--focused" })

--- Focused app introspectors

--- List introspectors, call back with a list of names
function m.introspector.list(callback)
	getter({ "introspector", "list" })(function(stdout, err)
		if not callback then
			return
		end
		if not stdout then
			callback(nil, err)
			return
		end
		local names = {}
		for name in stdout:gmatch("%S+") do
			table.insert(names, name)
		end
		callback(names)
	end)
end

m.introspector.get = getter({ "introspector", "get" })
m.introspector.get_command = getter({ "introspector", "get-command" })
--- App id of the focused client, as seen by the current introspector
m.introspector.get_focused = getter({ "introspector", "get-focused" })
--- set(introspector[, callback])
m.introspector.set = setter({ "introspector", "set" })
--- set_command(command[, callback])
m.introspector.set_command = setter({ "introspector", "set-command" })

return m
