local colormatch = "[a-fA-F0-9][a-fA-F0-9]"

num2hex = function(x)
	return string.format("%02x", x)
end

hex2num = function(x)
	return tonumber("0x" .. x)
end

local legitimize = function(v)
	if v < 0 then
		return 0
	elseif v > 255 then
		return 255
	end
	return math.floor(v + 0.5)
end

color_mix = function(c1, c2, r)
	local result = "#"
	assert(c1, "c1 must be a color string")
	assert(c2, "c2 must be a color string")

	r = r or 0.5
	-- create r, g, b, a iterator
	local c1 = c1:gmatch(colormatch)
	local c2 = c2:gmatch(colormatch)
	-- loop throught r, g, b, a
	local v, v1, v2
	for i = 1,3 do
		v1 = tonumber("0x" .. (c1() or "FF"))
		v2 = tonumber("0x" .. (c2() or "FF"))
		v = math.floor(v1*r + v2*(1 - r) + 0.5)
		v = legitimize(v)
		result = result .. string.format("%02x", v)
	end
	-- return
	return result
end

darker_color = function(c, n, method)
	method = method or mul
	assert(type(method) == "function", [[
		method must be a function (color value, scale) --> new value
	]])
	-- prepare some variable
	local result, cval = "#", nil
	local iter = c:gmatch(colormatch)
	-- loop through channels
	for _ = 1,3 do
		cval = tonumber("0x" .. iter())
		cval = method(cval, n)
		cval = string.format("%02x", legitimize(cval))
		result = result .. cval
	end
	-- return new color
	result = result .. (iter() or "FF" --[[ alpha ]])
	return result
end

isdarkcolor = function(c)
	local cval = 0
	local cniter = c:gmatch(colormatch)
	for cn = 1, 3 do
		cval = cval + tonumber("0x" .. cniter())
	end
	return cval < 383
end

choose_contrast_color = function (reference, candidate1, candidate2)  -- luacheck: no unused
	if isdarkcolor(reference) then
		if not isdarkcolor(candidate1) then
			return candidate1
		else
			return candidate2
		end
	else
		if isdarkcolor(candidate1) then
			return candidate1
		else
			return candidate2
		end
	end
end

reduce_contrast = function (color, ratio)
    ratio = ratio or 50
    return colors.darker(color, isdarkcolor(color) and -ratio or ratio)
end
