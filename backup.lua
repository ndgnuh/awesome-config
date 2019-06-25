local color = require("gears.color")
local notify = require("naughty").notify
local awful = require("awful")

-- change the awesome configset 
function change_config_set(name)
	config_file = os.getenv("HOME") .. '/.config/awesome/rc.lua'
	awful.spawn.easy_async_with_shell("cat " .. config_file .. " | sed s/^local configset = require(.*)/local configset = require('".. name .. "')/g | tee " .. config_file, function ()
		awesome.restart()
	end)
end

-- configset 
changemode = {
	{ "friendly", function () change_config_set("friendly") end }
}

dpi = require("beautiful.xresources").apply_dpi

function rgbToHex(rgb)
	local hexadecimal = '#'

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

function colormix(c1, c2, lv)
	local r1, g1, b1 = color.parse_color(c1)
	local r2, g2, b2 = color.parse_color(c2)
	local r = math.floor((255 * r1 * (1 - lv) + 255 * r2 * lv) + 0.5)
	local g = math.floor((255 * g1 * (1 - lv) + 255 * g2 * lv) + 0.5)
	local b = math.floor((255 * b1 * (1 - lv) + 255 * b2 * lv) + 0.5)
	return rgbToHex({r, g, b})
end

function colorcontrast(c)
	local r,g,b = color.parse_color(c)
	local luminate = 0.3*r + 0.587*g + 0.144*b
	if luminate > 0.5 then return "#32323D" else return "#fff5ee" end
end

function colorinvert(c)
	local r,g,b = color.parse_color(c)
	return rgbToHex({
		math.floor(255 - r*255 + 0.5),
		math.floor(255 - g*255 + 0.5),
		math.floor(255 - b*255 + 0.5),
	})
end

local configset = require("friendly")
require("mediakeys")
require("mediapopup")

