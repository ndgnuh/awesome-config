local gears = require"gears"
local loadmodule = require"mloader"

local module = loadmodule"new-config"

if type(module) ~= "table" then
  return
end

if module.globalkey_override then
  root.keys(globalkey)
elseif module.globalkey_append then
  root.keys(gears.table.join(root.keys(), globalkey))
end
