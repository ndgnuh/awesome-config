-- assert(awesomedir, "awesomedir is not defined")

local spawn = (require"awful.spawn").easy_async_with_shell
local gobj = require"gears.object"

local sh = gobj()

-- local shdir = awesomedir .. "/sh"
-- dump(debug.getinfo(1).source:sub(2):match("(.*/)"))
local shdir = debug.getinfo(1).source:sub(2):match("(.*/)")
local signal_extract = function(cmd)
	return cmd:match("^[^ ]+")
end

sh.dir = shdir
sh.mt = {}
sh.mt.__call = function(self, name)
	local file = string.format("%s/%s", self.dir, name)

	spawn(file, function(stdout, stderr)
		self:emit_signal(signal_extract(name), stdout, stderr)
	end)
end

sh.mt.__index = function(self, name)
	spawn(name, function(stdout, stderr)
		self:emit_signal(signal_extract(name), stdout, stderr)
	end)
end

return setmetatable(sh, sh.mt)
