local typesep, mm
local ptype = type
type = function(x)
    local pt = ptype(x)
    return pt == "table" and x.__datatype or pt
end

local db = require"util.Debug"
typesep = ";"

mm = function(gen, return_function_only)
  local f = {__generic = gen}
  -- don't use self here, if a function lives
  -- inside a table, the method may not be found
  f.addmethod = function(...)
    local types = ""
    local nargs = select("#", ...)
    for i = 1, nargs - 2 do
      types = types .. select(i, ...) .. typesep
    end
    types = types .. select(nargs - 1, ...)
    f[types] = select(nargs, ...)
    return f
  end
  f.setgeneric = function(m) f.__generic = m end
  f.getgeneric = function() return f.__generic end
  f.getmethod = function(...)
    local types = ""
    local nargs = select("#", ...)
    local method = f.__generic
    -- this way, even if there were vararg
    -- the proper method will be found
    -- if no method is found the generic will be called
    for i = 1, nargs do
      types = types .. type(select(i, ...))
      if f[types] then
        method = f[types]
      end
      types =  types .. typesep
    end
    return method
  end
  -- return the vtable, mostly for debug purpose
  f.call = function(...)
      local method = f.getmethod(...)
      if not method then error("no method found") end
      return method(...)
    end
  if return_function_only then
    -- return f + functions to set generic and methods
    return function(...) return call(f, ...) end, f.setgeneric, f.addmethod
  else
    return setmetatable(f, {__call = function(self, ...) self.call(...) end})
  end
end

return mm
