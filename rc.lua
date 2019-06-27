local color = require("gears.color")
local notify = require("naughty").notify
local awful = require("awful")
local config_file = os.getenv("HOME") .. '/.config/awesome/configset.lua'
require("constant")
dpi = require("beautiful.xresources").apply_dpi

-------------------------
--  Change config set  --
-------------------------
function change_config_set(name)
	update_cmd = "cat " .. config_file .. " | sed 's/.*/require(\""..name.."\")/g' | tee " .. config_file
	notify{ text = update_cmd }
	awful.spawn.easy_async_with_shell(update_cmd, function ()
		awesome.restart()
	end)
end

-- configset 
configsets = {
	{ "Basic", function () change_config_set("basic") end },
	{ "Guns girl", function () change_config_set("ggz") end },
	{ "Friendly", function () change_config_set("friendly") end },
	{ "Default", function () change_config_set("default") end }
} -- config set


----------------------------------
--  color processing functions  --
----------------------------------
function rgbtohex(rgb)
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
end -- rgb_to_hex

function colormix(c1, c2, lv)
	local r1, g1, b1 = color.parse_color(c1)
	local r2, g2, b2 = color.parse_color(c2)
	local r = math.floor((255 * r1 * (1 - lv) + 255 * r2 * lv) + 0.5)
	local g = math.floor((255 * g1 * (1 - lv) + 255 * g2 * lv) + 0.5)
	local b = math.floor((255 * b1 * (1 - lv) + 255 * b2 * lv) + 0.5)
	return rgbtohex({r, g, b})
end -- color mixer

function colorcontrast(c)
	local r,g,b = color.parse_color(c)
	local luminate = 0.3*r + 0.587*g + 0.144*b
	if luminate > 0.5 then return "#32323D" else return "#fff5ee" end
end -- find contrast color

function colorinvert(c)
	local r,g,b = color.parse_color(c)
	return rgbtohex({
		math.floor(255 - r*255 + 0.5),
		math.floor(255 - g*255 + 0.5),
		math.floor(255 - b*255 + 0.5),
	})
end -- find invert color

require("configset")

-------------------------------------
--  volume and brightness binding  --
-------------------------------------
require("mediakeys")
require("mediapopup")

------------
--  misc  --
------------

function colormarkup(s, c)
	return '<span color=\'' .. c .. '\'>' .. s .. '</span>'
end --colour markup
