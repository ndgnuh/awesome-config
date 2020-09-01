assert(awesomedir, "awesomedir not defined")
local gfs = re"gears.filesystem"

local icon_dir = awesomedir .. "/icon"

return function(name)
	local file = string.format("%s/%s", icon_dir, name)
	assert(gfs.file_readable(file), "icon " .. file .. " NOT found")
	return file
end
