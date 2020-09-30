-- assert(awesomedir, "awesomedir not defined")
-- local iconDir = awesomedir .. "/icon"
local Dir = require"Dir"
iconDir = Dir()

local gfs = require"gears.filesystem"

return function(name)
	assert(name, "icon name must not be nil")
	local file = string.format("%s%s", iconDir, name)
	assert(gfs.file_readable(file), "icon " .. file .. " NOT found")
	return file
end
