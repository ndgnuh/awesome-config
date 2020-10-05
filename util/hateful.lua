--- this module is made to read and write simple key - value config file
local module = {}
local io = require("io")
local getenv = require("os").getenv

local parsetype = function(v)
    if type(v) ~= "string" then return v end
    if v:match("%s*nil%s*") then return v end
    if v:match("%s*(%d+)%s*") then return tonumber(v) end
    if v:match("%s*(true)%s*") then return true end
    if v:match("%s*(false)%s*") then return false end
    return v
end

--[[ deserialize from string ]]
--[[ if a line is key = val then put it in the table ]]
--[[ if a line is { then put everything between {} on a string ]]
--[[ when a } is meet do recursive deserialize ]]
module.string_deserialize = function(s, throw)
  local obj = {}
  local r = 0
  local rs, key, val = "", "", ""
  s = s:gsub("%s*=%s*", "="):gsub("^%s*", ""):gsub("%s*$", "")
  for line in s:gmatch('[^\n]+') do
    if line:find("{") then
      if r == 0 then
        key = line:match("^%s*([a-zA-Z0-9_- ]+)%s*=")
      else
        rs = rs .. line .. "\n"
      end
      r = r + 1
    elseif line:find("}") then
      r = r - 1
      if r == 0 then
        obj[key] = module.string_deserialize(rs, throw)
        rs = ""
      else
        rs = rs .. line .. "\n"
      end
    elseif key and val then
      if r == 0 then
        key, val = line:match("%s*([a-zA-Z0-9_- ]+)%s*=%s*([{}a-zA-Z0-9_ -]+)%s*$")
        key, val = parsetype(key), parsetype(val)
        obj[key] = val
      else
        rs = rs .. line .. "\n"
      end
    elseif throw then
      error("Unknown syntax on line: " .. line)
    end
  end
  return obj
end

--[[ read all line in a file and deserialize it ]]
module.deserialize = function(f, throw)
  local s = f:read("*all")
  return module.string_deserialize(s, throw)
end

module.serialize = function(tbl, indent_level)
  if not indent_level then
    indent_level = 0
  end
  local indent = string.rep("\t", indent_level)
  local s = ""
  for k, v in pairs(tbl) do
    if type(k) ~= number then
      if type(v) == "table" then
        s = s .. indent .. tostring(k) .. " = {\n"
        s = s .. module.serialize(v, indent_level + 1)
        s = s .. "\n" .. indent .. "}\n"
      else
        s = s .. indent .. tostring(k) .. " = " .. tostring(v) .. "\n"
      end
    end
  end
  return s:sub(1,#s-1) --[[ remove trailing line ]]
end

-- [[ read config file, deserialize and cache it ]]
module.read = function(obj, ...)
  local file = io.open(obj.file, "r")
  --[[ if there's no file then use default or empty config ]]
  if not file then
    obj.cache = obj.default
  else
    obj.cache = module.deserialize(file, ...)
    file:close()
  end
end

--[[ write config file ]]
--[[ if there's no obj.cache ]]
--[[ then just close the file ]]
module.write = function(obj)
  local file = io.open(obj.file, "w")
  if obj.cache then
    local s = module.serialize(obj.cache)
    file:write(s)
  end
  file:close()
end

--[[ create a config object ]]
--[[ file: config file name ]]
--[[ default config: default config ]]
module.config = function(file, default, throw)
  local obj = {
    file = file,
    cache = nil,
    default = default or {}
  }
  obj.get = function(key)
    return obj.cache[key] or obj.default[key]
  end
  obj.set = function(key, val)
    obj.cache[key] = val
    obj.save()
  end
  obj.save = function()
    module.write(obj)
  end
  return setmetatable(obj, {
    __index = function(self, i)
      if i == "cache" and not rawget(self, "cache") then
        module.read(obj)
      end
      return rawget(self, i)
    end
  })
end

return module
