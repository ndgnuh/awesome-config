local getdir = function()
	return debug.getinfo(1).source:sub(2):match("(.*/)")
end

local _
local err, dir = pcall(getdir)
if err then
	assert(awesomedir, "awesomedir not defined")
else
	_, dir = dir:match("(/%a)*(%a)+/?")
end

require("util.Helper")

return true
