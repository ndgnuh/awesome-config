local gfs = require("gears.filesystem")
local cache_dir = gfs.get_cache_dir ()

local survival = {}
local function _serialize(obj, lookup, level, indent)
    if type(obj) == "string" then
        return '"'.. obj .. '"'
    elseif type(obj) == "number" or type(obj) == "boolean" or type(obj) == "nil" then
        return tostring(obj)
    elseif type(obj) ~= "table" then
        return "nil"
    end
    
    if lookup[obj] == 1 then
        return "nil"
    end
    
    lookup[obj] = 1
    local next_level = level+1
    local obj_str = "{\n"
    local thisindent = indent:rep(level)
    local nextindent = indent:rep(next_level)
    for k, v in pairs(obj) do
        obj_str = (
            obj_str .. nextindent ..
            "[" .. _serialize(k, lookup, next_level, indent) .. "] = " .. 
            _serialize(v, lookup, next_level, indent) .. ",\n"
        )
    end
    obj_str = obj_str .. thisindent .. "}"
    return obj_str
end

local function serialize(object, indent)
	indent = indent or "\t"
	local level = 0
	local lookup = {}
	return "return " .. _serialize(object, lookup, level, indent)
end

local function deserialize(str)
    return load(str)()
end

local function serialize_file(file, ...)
    local fp = io.open(file, "w")
    fp:write(serialize(...))
    fp:close()
end

local function deserialize_file(file, default)
    local fp = io.open(file)
    if not fp then
        return default
    else
        local obj = deserialize(fp:read("*a"))
        fp:close()
        return obj
    end
end


local function new(name)
    file = cache_dir .. "/" .. name
    return {
        serialize = function(...) return serialize_file(file, ...) end,
        deserialize = function(default) return deserialize_file(file, default) end,
    }
end


return setmetatable({
    serialize_file = serialize_file,
    deserialize_file = deserialize_file,
    serialize = serialize,
    deserialize = deserialize,
}, { __call = function(self, name) return new(name) end })
