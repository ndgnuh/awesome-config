assert(awesomedir, "awesomedir is not defined")

local awful = require("awful")
-- local sh = {}
-- 
shdir = awesomedir .. "/sh"
-- 
-- sh.file = function(name)
-- 	return string.format("%s/%s", sh.dir, name)
-- end
-- 
local defaul_callback = function(o, e)
	if e and e ~= "" then dump(e) end
end
return function(name, callback)
	awful.spawn.easy_async_with_shell(
		shdir .. "/" .. name,
		callback or defaul_callback)
end
-- 
-- sh.mt = {__call = sh.call}
-- 
-- return setmetatable(sh, sh.mt)
-- 
