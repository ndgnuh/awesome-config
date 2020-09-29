local gdb, notify, module

gdb = require"gears.debug"
notify = require"naughty".notify

module = {}

-- usage:{{{
-- f(x) --> f(dump(x))
module.dump = function(...)
  local dbo
  if select("#", ...) == 1 then
    dbo = gdb.dump_return(...)
  else
    dbo = gdb.dump_return({...})
  end
  notify {
    text = dbo,
    title = "Debug",
    timeout = 1000
  }
  return ...
end
--}}}

module.dumptype = function(...)
  local o, narg
  narg = select("#", ...)
  if narg == 1 then
    o = type(...)
  else
    o = {}
    for i = 1, narg do
      o[i] = type(select(i, ...))
    end
    module.dump(o)
  end
  return ...
end

return module
