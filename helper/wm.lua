local awful = require"awful"
local gears = require"gears"
local naughty = require"naughty"
local root = root

local module = {}

-- addkeys{{{
module.addkeys = function(...)
  return root.keys(gears.table.join(root.keys(), ...))
end
-- add buttons
module.addbuttons = function(buttons)
  return root.buttons(gears.table.join(keys, root.buttons()))
end
--}}}

-- dump everything{{{
module.dump = function(x)
  naughty.notify{
    text = gears.debug.dump_return(x),
    timeout = 999
  }
end
--}}}

return module
