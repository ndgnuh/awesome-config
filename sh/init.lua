assert(awesomedir, "awesomedir is not defined")

local awful = re"awful"
local gfs = re"gears.filesystem"

local shdir = awesomedir .. "/sh"
local defaul_callback = function(o, e)
	if e and e ~= "" then dump(e) end
end

return function(name, callback)
	local file = string.format("%s/%s", shdir, name)

	awful.spawn.easy_async_with_shell(
		shdir .. "/" .. name,
		callback or defaul_callback)
end
