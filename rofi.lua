local rofi = {}
local beautiful = require("beautiful")
local dump = require("gears.debug").dump_return
local awful = require("awful")

rofi.placement = {
	centered = "center",
	top = "north",
	bottom = "south",
	top_left = "north_west",
	top_right = "north_east",
	bottom_left = "south_west",
	bottom_right = "south_east",
	left = "west",
	right = "east",
}

rofi.prop = {
	bg = "background",
	fg = "color"
}

-- input style
local style = {}

style.rofi_common_background = "#FFFFFF" style.rofi_common_color = beautiful.white
style.rofi_window_position = rofi.placement.top
style.rofi_window_children = "[listview, inputbar]"
style.rofi_window_children = "[listview, inputbar]"
style.rofi_window_yoffset = 240
style.rofi_window_xoffset = 0
style.rofi_window_border = "5px" 
style.rofi_window_border_color = "5px" 
style.rofi_element_color = beautiful.white
beautiful.rofi_y_offset = beautiful.wibar_height * 2
beautiful.rofi_bg_selected = beautiful.colors.primary

function rofi.run(args)
	local s = rasify()
	awful.spawn.with_shell("rofi -theme-str '".. s .. "' " .. args)
end

local function interp(s, tab)
	return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

local theme = interp([[
* {
	background-color: ${bg_normal};
	background: ${bg_normal};
	border: 0px;
	margin: 0px;
	opacity: 0.8;
}
inputbar {
	padding: 8px;
	text-color: ${bg_focus};
	children: [prompt, textbox-prompt-colon, entry, case-indicator ];
}
#textbox-prompt-colon {
	expand: false;
	text-color: ${fg_focus};
}
textbox {
	color: ${fg_focus};
}
entry{
	color: ${fg_focus};
}
prompt{
	color: ${fg_focus};
}
window {
	location: north;
	y-offset: ${rofi_y_offset};
	background: transparent;
	children: [inputbar, listview];
}
listview {
	background-color: transparent;
	background: transparent;
	spacing: 0px;
}

element {
	margin: 4px;
	padding: 8px;
	border: 0px;
}
element alternate.normal{
	background-color: ${bg_normal};
	text-color: ${fg_normal};
}
element selected.normal{
	border-radius: 16px;
	background-color: ${rofi_bg_selected};
	text-color: ${fg_focus};
}
element normal.normal{
	background-color: ${bg_normal};
	text-color: ${fg_normal};
}
]], beautiful)

-- theme = theme:gsub("\n", " ")

local cmd = string.format("rofi -theme-str \"%s\" -show run", theme)

awful.spawn.with_shell(cmd)

local Rofi = {}

function Rofi.run()
	awful.spawn(cmd)
end

return Rofi
