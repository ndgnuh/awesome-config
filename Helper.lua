re = require
local pow = math.pow or function(x, y) return x^y end
local unpack = unpack or table.unpack
local naughty = re"naughty"
local ch = re"c_helper"
local gears = re"gears"

for v, func in pairs(require("c_helper")) do
	_G[v] = func
end


dpi = require("beautiful.xresources").apply_dpi

partial = function(f, x)
	return function(...)
		return f(x, ...)
	end
end

dump = function(x, tite)
	naughty.notify{
		title = title or "",
		text = gears.debug.dump_return(x)
	}
end

pass = function() end

grayscale = function(color)
	local c = gears.color(color)
	local err, r, g, b, a = c:get_rgba()
	assert(err, "Get rgba from " .. color .. " failed")
	local gray = pow(pow(r, 2.2) + pow(g, 2.2) + pow(b, 2.2), 1/2.2)
	return gears.color(gray, gray, gray, a)
end
