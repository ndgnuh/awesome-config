local DataType = {byname = {}, datatype = "DataType"}

do
  local ptype = type
  type = function(x)
    local pt = ptype(x)
    if pt == "table" and x.datatype then
      return x.datatype
    else
      return pt
    end
  end
end

DataType.new = function(name, constructor, meta)
  assert(name, "DataType need a name")
  local thetype = {datatype = "DataType", name = name, meta = meta}

  local tostringfn = function(self)
    local addr = tostring(self):gsub("table:", "")
    return function(self)
      local ret = self.datatype .. addr
      for k, v in pairs(self) do
        if k ~= "datatype" then
          ret = ret .. "\n\t" .. k .. ": " .. v
        end
      end
      return ret
    end
  end

  -- create default constructor
  if not constructor then
    constructor = function(...)
      local obj = {datatype = name}
      meta = meta or {}
      meta.__tostring = meta.__tostring or tostringfn(obj)
      return setmetatable(obj, meta)
    end
  end

  local call = function(self, ...)
    local obj = constructor(...)
    meta = meta or {}
    meta.__tostring = meta.__tostring or tostringfn(obj)
    obj.datatype = self.name
    return setmetatable(obj, meta)
  end

  local tostring = function(self)
    local ret = self.datatype
    for k, v in pairs(self) do
      ret = ret .. "\n"
    end
  end

  return setmetatable(thetype, {__call = call, __tostring = function(self) return "[DataType] " .. self.name end})
end

DataType = setmetatable(DataType, {
    __call = function(self, name, ...)
      local ret = self.new(name, ...)
      self.byname[name] = ret
      return ret
    end,
    __index = function(self, name)
      return rawget(rawget(self, "byname"), name)
    end,
  })

return DataType
