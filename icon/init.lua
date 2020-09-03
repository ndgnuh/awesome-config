-- assert(awesomedir, "awesomedir not defined")
-- local iconDir = awesomedir .. "/icon"
local iconDir = debug.getinfo(1).source:sub(2):match("(.*/)")

local gfs = re"gears.filesystem"

return function(name)
	local file = string.format("%s/%s", iconDir, name)
	assert(gfs.file_readable(file), "icon " .. file .. " NOT found")
	return file
end
