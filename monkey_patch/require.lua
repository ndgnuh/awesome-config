--- Extended `require`
--- Usage:
---   local r = require("monkey_patch.require")
---   r("gears")              -- regular require
---   r.force("ndgnuh.theme") -- require, bypassing the cache
---   r.rel("sibling")        -- require relative to the caller's file
---   r.patch()               -- replace the global `require` with this module

local gears = require("gears")

local m = {}

--- The original require, captured before any patching
m.original = require

---Require a module, ignoring the cache.
---@param name string The module name
---@return any
function m.force(name)
	package.loaded[name] = nil
	return m.original(name)
end

---Require a module relative to the caller's directory.
---The caller's directory is converted to a module prefix (relative to the configuration directory).
---Example: in `bars/wibar.lua`, `rel("taglist")` is `require("bars.taglist")`.
---@param name string The module name, relative to the caller's directory
---@return any
function m.rel(name)
	local info = debug.getinfo(2, "S")
	local config_dir = gears.filesystem.get_configuration_dir()
	local source = info.source:gsub("@", ""):gsub(config_dir, "")
	local source_dir = source:match("^(.*)/[^/]*$")
	if not source_dir then
		return m.original(name)
	end
	local mod = source_dir:gsub("/", ".")
	return m.original(mod .. "." .. name)
end

---Replace the global `require` with this module.
function m.patch()
	_G.require = m
end

return setmetatable(m, {
	__call = function(_, ...)
		return m.original(...)
	end,
})
