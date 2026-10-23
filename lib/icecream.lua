---[[-- The icecream debugger.
-- Some version of icecream allows initializing multiple instance of `icecream`,
-- but I think one is enough. Using icecream will dump the exact variable names,
-- so you now exactly what is being dump.
--
-- <h3>Usage:</h3>
--
--      local ic = require("icecream")
--      ic() -- line number
--      ic("String") -- basic data
--      ic("ABC", {}, 3) -- dump multiple
--      ic({ x = 1, y = 2, { 0, z = "AbC" } }) -- dump table
--
-- @module libs.icecream
-- @author ndgnuh
-- @release 2024.01.26
--
local gears = require("gears")
local naughty = require("naughty")

local icecream = { prefix_string = "ic| ", mt = {} }

--- Show the given message, this version uses AwesomeWM's <code>naughty</code> module.
-- @tparam string msg the object content or the trace info
-- @tparam string obj the object name?
function icecream.output(msg, obj)
	local title = icecream.prefix_string .. tostring(obj)
	naughty.notification({
		preset = naughty.config.presets.warn,
		title = title,
		message = msg,
		font = "monospace 8",
		timeout = 32000,
	})
end

--- Dump the position in the code
function icecream:ic_position() end

--- Read names from source at some line
--
-- The function tries to match the parentheses and curly braces.
-- @tparam string sourcefile Source file
-- @tparam int line Start line number
-- @treturn {string} A table of names strings
function icecream.read_names(sourcefile, line)
	local fp = io.open(sourcefile)
	if fp == nil then
		return {}
	end

	-- Seek line
	for _ = 1, line - 1 do
		fp:read()
	end

	-- Read the rest
	local source = fp:read("*a")
	fp:close()

	-- Check if the call is ic( ... or ic{
	local first
	for i = 1, 100 do
		local c = source:sub(i, i)
		if c == "{" or c == "(" then
			first = c
			break
		end
	end

	-- match the depends on the first character, do some early returns
	local matches
	if first == "(" then
		matches = source:match("(%b())")
		matches = matches:sub(2, #matches - 1):gsub("\n", ""):gsub(" ", ""):gsub("\r", "")
	elseif first == "{" then
		matches = source:match("(%b{})")
		return { matches }
	else
		return { "unknown" }
	end

	-- parse names (first, curly)
	local curly = 0 -- curly brace stack
	local name = "" -- current name
	local names = {} -- list of names
	local nchars = #matches
	for i = 1, nchars do
		local char = matches:sub(i, i)
		name = name .. char

		-- found a name, append and reset
		if (char == "," or char == ")") and curly == 0 and i > 0 then
			-- format the table a bit
			name = name:sub(1, #name - 1):gsub(",}", "}"):gsub(",", ", "):gsub("=", ": ")
			table.insert(names, name)
			name = ""
			goto continue
		end

		-- last character
		if i == nchars and #name > 0 then
			table.insert(names, name)
			goto continue
		end

		-- stack push/pull for matching
		if char == "{" then
			curly = curly + 1
		end
		if char == "}" then
			curly = curly - 1
		end
		-- (first = false
		::continue::
	end

	-- Close and return
	return names
end

--- Process and print the corresponding variable name and variable value
-- @param ... Anything, if empty, the position is dump
-- @usage ic() -- line number
-- @usage ic("String") -- basic data
-- @usage ic("ABC", {}, 3) -- dump multiple
-- @usage ic({ x = 1, y = 2, { 0, z = "AbC" } }) -- dump table
function icecream:ic(...)
	local nargs = select("#", ...)
	if nargs == 0 then
		-- it is the number of backward walks on the traceback
		local traceback = gears.string.split(debug.traceback(), "\n")
		local stack = string.match(traceback[4], "^%s*(.-)%s*$")

		-- naughty.notify { text = gears.debug.dump_return(traceback), timeout= 0 }
		-- remove the conguration directory because we don't need those
		local root = gears.filesystem.get_configuration_dir()
		stack = stack:gsub(root, "")

		-- dump every thing
		return icecream.output(stack, "")
	end

	-- Get the argument names
	-- use previous frame for variable name
	local traceback = gears.string.split(debug.traceback(), "\n")
	local stack = string.match(traceback[#traceback - 1], "^%s*(.-)%s*$")
	local buffer = gears.string.split(stack, ":")
	local filename = buffer[1]
	local line = buffer[2]
	local names = icecream.read_names(filename, line)

	-- Dump
	local value, name
	for i = 1, nargs do
		value = select(i, ...)
		value = gears.debug.dump_return(value)
		name = names[i]
		icecream.output(value, name)
	end
end

--- Set the prefix string when printing source
-- @tparam string val The prefix string
function icecream.set_prefix(val)
	icecream.prefix_string = val
end

--- Fallback to the default prefix string when printing source
function icecream.reset_prefix()
	icecream.prefix_string = "ic| "
end

--- Meta method to call `ic` using the `icecream` table
-- @function __call
-- @param ... Same as `ic`.
function icecream.mt:__call(...)
	icecream:ic(...)
end

return setmetatable(icecream, icecream.mt)
