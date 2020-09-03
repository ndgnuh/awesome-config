local unpack = unpack or table.unpack
local fine1, gears = pcall(require, "gears")
local fine2, naughty = pcall(require, "naughty")
local ch = require("c_helper")

for v, func in pairs(require("c_helper")) do
	_G[v] = func
end


dpi = require("beautiful.xresources").apply_dpi

partial = function(f, x)
	return function(...)
		return f(x, ...)
	end
end

if fine1 and fine2 then
	dump = function(x, tite)
		naughty.notify{
			title = title or "",
			text = gears.debug.dump_return(x)
		}
	end
else
	dump = function(...)
		print("Naughty and gears not found")
	end
end

pass = function() end

-- doesn't work, this debug line must be placed where the file is
-- __dir__ = function()
-- 	return debug.getinfo(1).source:sub(2):match("(.*/)")
-- end

re = require


