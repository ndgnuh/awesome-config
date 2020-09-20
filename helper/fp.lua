-- helper module
-- export:
-- * map
-- * partial1, partial2, partial3
local module = {}

-- map{{{
-- f: the function to map to each element
-- t: the table to map
module.map = function(f, t)
  local ts = {}
  for k, v in pairs(t) do
    ts[k] = f(v)
  end
  return ts
end
--}}}

-- partial application{{{
-- do partial application with n predefined arg(s)
module.partial = function(f, x)
  return function(...)
    return f(x, ...)
  end
end
module.partial2 = function(f, x, y)
  return function(...)
    return f(x, y, ...)
  end
end
module.partial3 = function(f, x, y, z)
  return function(...)
    return f(x, y, z, ...)
  end
end
--}}}

-- range{{{
-- args:
-- * start, step, stop
-- * start, stop
-- * stop
-- default:
-- * start = 1
-- * step = 1
module.range = function(...)
  local narg = select("#", ...)
  local start, step, stop, ret = 1, 1, 1, {}
  if narg == 1 then
    stop = ...
  elseif narg == 2 then
    start, stop = ...
  else
    start, step, stop = ...
  end
  local x = start
  while x <= stop do
    table.insert(ret, x)
    x = x + step
  end
  return ret
end
--}}}

return module
