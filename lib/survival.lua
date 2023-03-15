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

local function deserialize(self, str) end

local function new(name) end


return {
    serialize = serialize,
    deserialize = deserialize
}
