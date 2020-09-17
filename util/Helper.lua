re = require
local pow = math.pow or function(x, y) return x^y end
local unpack = unpack or table.unpack
local naughty = re"naughty"
local gears = re"gears"

dpi = require("beautiful.xresources").apply_dpi

partial = function(f, x)
	return function(...)
		return f(x, ...)
	end
end

dump = function(x, tite)
	naughty.notify{
		timeout = 999,
		title = title or "",
		text = gears.debug.dump_return(x)
	}
end

pass = function() end

grayscale = function(color)
	local err, r, g, b, a
	if type(color) == "string" then
		r, g, b, a = gears.color.parse_color(color)
		dump{r,g,b,a}
	else
		err, r, g, b, a = c:get_rgba()
		assert(err, "Get rgba from " .. color .. " failed")
	end
	local clinear = 0.3*r + 0.59*g + 0.11*b
	local gray
	if clinear > 0.0031308 then
		gray = 1.055 * pow(clinear, 2.4) - 0.055
	else
		gray = 12.92 * clinear
	end
	return gears.color(gray, gray, gray)
end
