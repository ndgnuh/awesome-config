local unpack = unpack or table.unpack
local fine1, gears = pcall(require, "gears")
local fine2, naughty = pcall(require, "naughty")

dpi = require("beautiful.xresources").apply_dpi

partial = function(f, x)
	return function(...)
		return f(x, ...)
	end
end

map = function(f, tbl)
	t = {}
	for k,v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end

bmap = function(f, ...)
	return unpack(map(f, {...}))
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

re = require
