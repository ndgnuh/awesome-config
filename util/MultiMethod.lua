-- # Sample usage
-- vtable = {
--     [{"string", "string"}] = function(x, y) return x .. y end,
--     [{"string", "number"}] = function(x, y) return x .. tostring(y + 1) end,
--     [{"number"}] = function(x) return x + 1 end,
--     [{}] = function() print("hello world") end
-- }
-- f = multimethod(vtable)
-- calls:
-- f("hello", "world")
-- f("hello", 1)
-- f(1)
-- f()
local unpack = unpack or table.unpack
local module, private
private = {}

-- override the type function
do
  local ptype = _G.type
  _G.type = function(x)
    local pt = ptype(x)
    if pt == "table" then
      return x.__datatype or pt
    end
    return pt
  end
end

-- get/set recursively{{{
private._setr = function(t, ind, maxind, ...)
  local k = select(ind, ...)
  if ind == maxind then
    t.__private = k
  else
    if not t[k] then
      t[k] = {}
    end
    return private._setr(t[k], ind + 1, maxind, ...)
  end
end
private.setr = function(t, ...)
  private._setr(t, 1, select("#", ...), ...)
  return t
end
private._getr = function(t, ind, maxind, found, ...)
  local k = select(ind, ...)
  local v = t[k]
  if not v then return found end
  if v.__private then
    found = v.__private
  end
  if ind == maxind then
    return v.__private or found
  else
    return private._getr(v, ind + 1, maxind, found, ...)
  end
end
private.getr = function(t, ...)
  return private._getr(t, 1, select("#", ...), nil, ...)
end
--}}}

-- create new function base on method definition{{{
module = function(vtable)
  local vt = {}
  -- call method
  local call = function(self, ...)
    local f = self:getmethod(...) or self:getgeneric()
    assert(f, "No such method")
    return f(...)
  end
  -- if there's a vtable then append the method
  if type(vtable) == "table" then
    for dispatch, method in pairs(vtable) do
      table.insert(dispatch, method)
      chainset(vt, unpack(dispatch))
    end
  end
  -- add new method to function
  vt.addmethod = private.setr
  vt.getmethod = function(self, ...)
    return private.getr(self, ...)
  end
  vt.setgeneric = function(self, f)
    self.__private = f
  end
  vt.getgeneric = function(self, f)
    return self.__private
  end
  -- return multimethod function
  return setmetatable(vt, {__call = call})
end
--}}}

require"util.Debug".dump("Mulitmethod is used")
--{{{
return module
--}}}

