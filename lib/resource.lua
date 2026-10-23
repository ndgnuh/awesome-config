--- Module for working with resources in the configuration directory
--- There are function to get resources and there are presets top
--- reduce magic values.
---
--- functions:
---     - m.resource (get resource)
---     - m.icon (get icon + recolor)
local gears = require("gears")
local m = {}

local config_dir = gears.filesystem.get_configuration_dir()

---Get full path to resource in the configuration directory
---@param path string Path to resource file.
---@return string _ Full path to the resource
function m.resource(path)
	return config_dir .. path
end

---Resolves an icon path and optionally recolors it
---@param path string the relative or full path to the icon resource
---@param color string|table|cairo_pattern|nil the color specification to apply to the image (optional)
---@return string|cairo_surface _ the resolved file path or the recolored Cairo surface
function m.icon(path, color)
	local iconpath = m.resource(path)
	if color then
		return gears.color.recolor_image(iconpath, color)
	else
		return iconpath
	end
end

---Returns hex string with hsl color values
---@param H number hue value, between 0 and 360
---@param L number lightness value, between 0 and 1
---@param S number saturation value, between 0 and 1
---@return string hex the hex string of the input color
function m.hsl(H, S, L, a)
	a = a or 1
	H = H % 360

	-- aux variables
	local C = (1 - math.abs(2 * L - 1)) * S
	local X = C * (1 - math.abs((H / 60) % 2 - 1))
	local m_ = L - C / 2

	-- Compute rgb value
	local r, g, b = 0, 0, 0
	if H < 60 then
		r, g, b = C, X, 0
	elseif H < 120 then
		r, g, b = X, C, 0
	elseif H < 180 then
		r, g, b = 0, C, X
	elseif H < 240 then
		r, g, b = 0, X, C
	elseif H < 300 then
		r, g, b = X, 0, C
	else
		r, g, b = C, 0, X
	end
	r, g, b = r + m_, g + m_, b + m_

	-- Convert to hexstring
	local hex_r = string.format("%02x", math.floor(r * 255 + 0.5))
	local hex_g = string.format("%02x", math.floor(g * 255 + 0.5))
	local hex_b = string.format("%02x", math.floor(b * 255 + 0.5))
	local hex_a = string.format("%x", math.floor(a * 255 + 0.5))
	local color = "#" .. hex_r .. hex_g .. hex_b .. hex_a
	return color
end

---Returns hex string with rgb color values
---@param r number red value, between 0 and 255
---@param g number green value, between 0 and 255
---@param b number blue value, between 0 and 255
---@return string hex the hex string of the input color
function m.rgb(r, g, b)
	local rhex = string.format("%x", r)
	local ghex = string.format("%x", g)
	local bhex = string.format("%x", b)
	rhex = #rhex < 2 and "0" .. rhex or rhex
	ghex = #ghex < 2 and "0" .. ghex or ghex
	bhex = #bhex < 2 and "0" .. bhex or bhex
	return "#" .. rhex .. ghex .. bhex
end

---Converts floating-point RGB values (0-1) to 8-bit integers (0-255) and returns the formatted RGB color
---@param r number red value, normalized between 0 and 1
---@param g number green value, normalized between 0 and 1
---@param b number blue value, normalized between 0 and 1
---@return string hex the hex output color result from m.rgb
function m.rgbf(r, g, b)
	r = math.floor(r * 255 + 0.5)
	g = math.floor(g * 255 + 0.5)
	b = math.floor(b * 255 + 0.5)
	return m.rgb(r, g, b)
end

return m
