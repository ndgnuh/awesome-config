local unpack = unpack or table.unpack
local Module = {
  function(f, x1)
    return function(...)
      return f(x1, ...)
    end
  end,
  function(f, x1, x2)
    return function(...)
      return f(x1, x2, ...)
    end
  end,
  function(f, x1, x2, x3)
    return function(...)
      return f(x1, x2, x3, ...)
    end
  end,
  function(f, x1, x2, x3, x4)
    return function(...)
      return f(x1, x2, x3, x4, ...)
    end
  end,
  function(f, x1, x2, x3, x4, x5)
    return function(...)
      return f(x1, x2, x3, x4, x5, ...)
    end
  end,
  function(f, x1, x2, x3, x4, x5, x6)
    return function(...)
      return f(x1, x2, x3, x4, x5, x6, ...)
    end
  end,
  function(f, x1, x2, x3, x4, x5, x6, x7)
    return function(...)
      return f(x1, x2, x3, x4, x5, x6, x7, ...)
    end
  end,
  function(f, x1, x2, x3, x4, x5, x6, x7, x8)
    return function(...)
      return f(x1, x2, x3, x4, x5, x6, x7, x8, ...)
    end
  end,
  function(f, x1, x2, x3, x4, x5, x6, x7, x8, x9)
    return function(...)
      return f(x1, x2, x3, x4, x5, x6, x7, x8, x9, ...)
    end
  end
}

local call = function(self, f, ...)
  local narg = select("#", ...)
  assert(narg > 0, "Can't do partial application without arguments")
  local pt = self[narg]
  if type(pt) ~= "function" then
    local args = {...}
    return function(...)
      local newargs = {unpack(args), ...}
      return f(unpack(newargs))
    end
  else
    return pt(f, ...)
  end
end

return setmetatable(Module, {__call = call})
