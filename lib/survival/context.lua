local gears = require("gears")
local gfs = require("gears.filesystem")
local core = require.rel("core")

---Survival context, (de)serialize directly from and to `target_path`.
---@class survival.context
local context = {}

---Path to the serialized file, `cache_dir/survival/{name}.lua`
---@type string
context.target_path = ""

---Serialize object to `target_path`
---@param object any lua-native object
---@param indent? string indentation for the serialized code, default to "\t"
function context:serialize(object, indent)
	return core.serialize_file(self.target_path, object, indent)
end

---Deserialize object from `target_path`
---@generic T
---@param default? T the value to be returned if the file can't be read
---@return any|T obj the deserialized object, or `default`
function context:deserialize(default)
	return core.deserialize_file(self.target_path, default)
end

--- Create a new survival context
--- @return survival.context
local function new(prototype, name)
	local cache_dir = gfs.get_cache_dir()
	local target_path = cache_dir .. "/survival/" .. name .. ".lua"
	gfs.make_parent_directories(target_path)

	local new_context = gears.table.clone(prototype)
	new_context.target_path = target_path
	return new_context
end

setmetatable(context, { __call = new })

return context
