-- shorter require
local re = function(name) return require("helper." .. name) end

local fp = re"fp"
local wm = re"wm"

return fp
