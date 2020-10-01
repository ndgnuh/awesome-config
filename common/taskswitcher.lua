-- do not `require` this file
-- it was made only to shorten the common.lua file
local common = ...
if not common then return nil end

common:emit_signal("add", "taskswitcher", function(_, mod)
  modkey = modkey or "Mod4"
  local wm = require("helper.wm")
  local awful = require"awful"
  local mod = {modkey}
  local ts = require"TaskSwitcher"()
  wm.addkeys(
    awful.key(mod, "j", function() ts:trigger() ts:emit_signal("forward") end),
    awful.key(mod, "k", function() ts:trigger() ts:emit_signal("backward") end)
    )
end)

return common
