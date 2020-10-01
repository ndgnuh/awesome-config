local Hateful = {}

Hateful.dump = function(self, table, level, shown)
  shown = shown or {}
  level = level or 1
  if level == 1 then
    shown[self] = true
  end
  -- doesn't handle cyclic reference
  if level > 100 then
    return "Overflow"
  end
  local ret = ""
  local keypart, valuepart
  local auxstart, auxend = "", ""
  local indent = "\t"
  for k, v in pairs(table) do
    if type(k) == "number" or type(k) == "boolean" then
      keypart = string.format("[%s]", k)
    else
      keypart = tostring(k)
    end
    if type(v) == "string" then
      valuepart = string.format([["%s"]], v)
    elseif type(v) == "table" then
      print(v, shown[v])
      if shown[v] then
        valuepart = tostring(v)
      else
        shown[v] = true
        valuepart = self:dump(v, level + 1, shown)
      end
    else
      valuepart = v
    end
    ret = ret .. "\n" ..
    string.format("%s%s = %s,", indent:rep(level), keypart, valuepart)
  end
  return string.format("{%s\n%s}", ret, indent:rep(level - 1))
end

Hateful.write = function(file, tbl)
  local dmp = Hateful:dump(tbl)
  local reformat = string.format([[return %s]], dmp)
  io.open(file):write(reformat)
  return file, tbl
end

Hateful.read = function(file)
  local name = file:match("[^/]+%.lua"):gsub("%.lua", "")
  return require(name)
end

Hateful.getconfig = function(file)
  local ret = {
    __file = file,
    __obj = nil,
    __read = false,
  }
  local mt = {
    __index = function(self, i)
      local file = rawget(self, "__file")
      if not rawget(self, "__read") then
        rawset(self, "__obj", Hateful.read(file))
        rawset(self, "__read", true)
      end
      return rawget(self, obj)[i]
    end,
    __newindex = function(self, i, v)
      local file = rawget(self, "__file")
      local obj = rawget(self, "__obj")
      if not rawget(self, "__read") then
        rawset(self, "__obj", Hateful.read(file))
        rawset(self, "__read", true)
      end
      obj[i] = v
      Hateful.write(file, obj)
      return self, i, v
    end,
  }
  return setmetatable(ret, mt)
end

return Hateful
