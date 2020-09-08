local color = re"gears.color"
local html = color.parse_color
local ceil = math.ceil

local colormatch = "[a-fA-F0-9][a-fA-F0-9]"

local num2hex = function(x)
	x = ceil(tonumber(x) * 255)
	return string.format("%02x", x)
end

local hex2num = function(x)
	return tonumber("0x" .. x)
end

local num2hex_color = function(r, g, b, a)
	return string.format("#%s%s%s%s", vmap(num2hex, r, g, b, a))
end

local legitimize = function(v)
	return v < 0 and 0 or (v > 255 and 255) or v
end

mix = function(c1, c2, r)
	local result = "#"
	r = r or 0.5
	-- create r, g, b, a iterator
	local c1 = c1:gmatch(colormatch)
	local c2 = c2:gmatch(colormatch)
	-- loop throught r, g, b, a
	local v, v1, v2
	for i = 1,4 do
		v1 = tonumber("0x" .. (c1() or "FF"))
		v2 = tonumber("0x" .. (c2() or "FF"))
		v = math.floor(v1*r + v2*(1 - r) + 0.5)
		v = legitimize(v)
		result = result .. string.format("%02x", v)
	end
	-- return
	return result
end
