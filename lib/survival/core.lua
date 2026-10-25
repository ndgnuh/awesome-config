--[[-- This module serialize and deserialize lua objects to/from lua code.
The serialized code is stored in the cache directory, the purpose of this module
is the built other functionalities such as settings or layout preservation.

@usage
-- Usage with context
-- Create a context
local survival = require("survival")
local ctx = survival("settings") -- settings is just a name

-- load and save using the context
local default_settings = { terminal = "sakura", modkey = "Mod4" }
local settings = ctx.deserialize() or default_settings -- load
ctx.serialize(settings) -- save

@usage -- Without context
local survival = require("survival")
local obj = { x = 1, y = 2 }

-- Serialize to string
local code = survival.serialize(obj)
local obj_dec = survival.deserialize(code)

-- Serialize to file
survival.serialize_file("output.lua", obj)
local obj = survival.deserialize_file("output.lua")

@usage -- Spawn a command once, the PID is cached so it survives WM restarts
local survival = require("survival")
survival.spawn.once("picom") -- does nothing if picom is still running
local pid = survival.spawn.get_active_pid("picom") -- nil if not running
--]]
local gfs = require("gears.filesystem")
local survival = {}

--- The recursive serializer function
-- @param obj : object to be serialized
-- @tparam table lookup : table to look up for recursive object
-- @tparam number level : recursion depth
-- @tparam number indent : indentation
-- @treturn string : the serialized object
function survival._serialize(obj, lookup, level, indent)
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
            "[" .. survival._serialize(k, lookup, next_level, indent) .. "] = " ..
            survival._serialize(v, lookup, next_level, indent) .. ",\n"
        )
    end
    obj_str = obj_str .. thisindent .. "}"
    return obj_str
end

--- User API serialize function
-- @param object : lua object to be serialized
-- @tparam number indent : level of lua code indentation
-- @treturn string: a valid lua code to load the serialized object
survival.serialize = function(object, indent)
    indent = indent or "\t"
    local level = 0
    local lookup = {}
    return "return " .. survival._serialize(object, lookup, level, indent)
end

--- Deserialize lua object from string
--
-- Warning: this function is not safe at all since it loads lua code from file.
-- @tparam string code : serialized lua code
-- @return The deserialized object
survival.deserialize = function(code)
    return load(code)()
end

--- Serialize lua object to file
--
-- @tparam string file : target output file
-- @param object : any lua-native object
-- @tparam number indent : indentation level for the serialized code
survival.serialize_file = function(file, object, indent)
    local fp = io.open(file, "w")
    if fp ~= nil then
        fp:write(survival.serialize(object, indent))
        fp:close()
    end
end

--- Deserialize lua object
--
-- Warning: this function is not safe at all, it just load the
-- function returned by the lua file and call that function.
-- @tparam string file : path to serialized lua file
-- @param default : the value to be returned if the file can't be serialized
-- @return The serialized object, if the file cannot be openned, return default
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


--- Create new survival context.
--
-- This function returns a table with have serialize, deserialize functions.
-- that (de)serialize directly from and to the target file.
-- The target file will be `cache_dir/survival/{namespace}.lua`.
-- @tparam string name : the name of the serialization namespace
-- @treturn table : survival context
-- @field target_path : path to the serialized file
-- @field serialize : Serialize object to `target_path`, takes `(object, indent)`
-- @field deserialize : Deserialize object from `target_path`, takes `(default)`
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
