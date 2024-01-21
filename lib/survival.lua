--- This module serialize and deserialize lua objects to/from lua code.
-- The serialized code is stored in the cache directory, the purpose of this module
-- is the built other functionalities such as settings or layout preservation.
local gfs = require("gears.filesystem")
local survival = {}

--- The recursive serializer function
--- @param obj any: object to be serialized
--- @param lookup table: table to look up for recursive object
--- @param level integer: recursion depth
--- @param indent integer: indentation
local function _serialize(obj, lookup, level, indent)
    if type(obj) == "string" then
        return '"' .. obj .. '"'
    elseif type(obj) == "number" or type(obj) == "boolean" or type(obj) == "nil" then
        return tostring(obj)
    elseif type(obj) ~= "table" then
        return "nil"
    end

    if lookup[obj] == 1 then
        return "nil"
    end

    lookup[obj] = 1
    local next_level = level + 1
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

--- User API serialize function
--- @param object any: lua object to be serialized
--- @param indent integer: level of lua code indentation
--- @return string: a valid lua code to load the serialized object
survival.serialize = function(object, indent)
    indent = indent or "\t"
    local level = 0
    local lookup = {}
    return "return " .. _serialize(object, lookup, level, indent)
end

--- Deserialize lua object from string
--- Warning: this function is not safe at all for obvious reason.
--- @param code string: path to serialized lua file
--- @return any: the serialized object
survival.deserialize = function(code)
    return load(code)()
end

--- Serialize lua object to file
--- @param file string: target output file
--- @param object any: any lua-native object
--- @param indent integer: indentation level for the serialized code
survival.serialize_file = function(file, object, indent)
    local fp = io.open(file, "w")
    if fp ~= nil then
        fp:write(survival.serialize(object, indent))
        fp:close()
    end
end

--- Deserialize lua object
--- Warning: this function is not safe at all, it just load the
--- function returned by the lua file and call that function.
--- @param file string: path to serialized lua file
--- @return any: the serialized object, if the file cannot be openned, return nil
survival.deserialize_file = function(file, default)
    local fp = io.open(file)
    if not fp then
        return default
    else
        local obj = survival.deserialize(fp:read("*a"))
        fp:close()
        return obj
    end
end


--- Create new survival context
-- The returned object have serialize, deserialize functions
-- that (de)serialize directly from and to the target file.
-- THe target file will be "cache_dir/survival/{namespace}.lua"
--- @param name string: the name of the serialization namespace
--- @return table: survival context
survival.context = function(name)
    local context = {}
    local cache_dir = gfs.get_cache_dir()
    context.target_path = cache_dir .. "/survival/" .. name .. ".lua"
    gfs.make_parent_directories(context.target_path)
    context.serialize = function(...) return survival.serialize_file(context.target_path, ...) end
    context.deserialize = function(default) return survival.deserialize_file(context.target_path, default) end
    return context
end


return setmetatable(survival, { __call = function(self, name) return survival.context(name) end })
