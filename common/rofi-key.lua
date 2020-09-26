-- spawner
-- module.addkey(mod, key, cmd, callback, desc)
-- * add key to global keys
-- module.addbutton(mod, key, cmd, callback, desc)
-- * add button to global buttons
local module = {}

-- module.add(args, fn){{{
-- where fn = awful.button | awful.key
module.add = function(fn, mod, key, cmd, callback, desc)
  assert(type(arg) == "table")
  local wm = require"wm"
  local awful = require"awful"
  -- if there's callback
  local func = nil
  if type(callback) == "function" then
    func = function()
      awful.spawn.easy_async_with_shell(cmd, callback)
    end
  else
    func = function()
      awful.spawn.with_shell(cmd)
    end
  end
  if fn == awful.button then
    wm.addkeys(btn(mod, key, func, arg.desc))
  else
  end
end
--}}}

return module
