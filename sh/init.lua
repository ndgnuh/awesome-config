-- assert(awesomedir, "awesomedir is not defined")

local awful = re"awful"
local gfs = re"gears.filesystem"

-- local shdir = awesomedir .. "/sh"
-- dump(debug.getinfo(1).source:sub(2):match("(.*/)"))

local shdir = debug.getinfo(1).source:sub(2):match("(.*/)")

local defaul_callback = function(o, e)
	if e and e ~= "" then dump(e) end
end

return function(name, callback)
	local file = string.format("%s/%s", shdir, name)

	awful.spawn.easy_async_with_shell(
		shdir .. "/" .. name,
		callback or defaul_callback)
end
