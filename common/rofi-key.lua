-- do not `require` this file
-- it was made only to shorten the common.lua file
local common = ...
assert(common, "Do not require this file")

common:emit_signal("add", "taskswitcher", function(_, mod, key)
  mod = mod or {"Mod4"}
  key = key or "r"
  local wm = require"helper.wm"
  local awful = require"awful"
  wm.addkeys(awful.key(mod, key, function()
    awful.spawn, "rofi -show combi -modi"
  end))
end)
