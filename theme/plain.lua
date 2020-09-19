local icon = require"icon"
local gears = require"gears"

-- shorts {{{
local dpi = require("beautiful.xresources").apply_dpi
local recolor = gears.color.recolor_image
--}}}

local theme = {}

-- tput colors{{{
-- 0: black
-- 1: red
-- 2: green
-- 3: yellow
-- 4: blue
-- 5: magenta
-- 6: cyan
theme.color0     = "#000000"
theme.color1     = "#DD0000"
theme.color2     = "#00DD00"
theme.color3     = "#DDDD00"
theme.color4     = "#0000DD"
theme.color5     = "#DD00DD"
theme.color6     = "#00DDDD"
theme.color7     = "#DDDDDD"
-- bright colors
theme.color8     = "#222222"
theme.color9     = "#FF0000"
theme.color10    = "#00FF00"
theme.color11    = "#FFFF00"
theme.color12    = "#0000FF"
theme.color13    = "#FF00FF"
theme.color14    = "#00FFFF"
theme.color15    = "#FFFFFF"
--}}}

-- standard variables {{{
theme.bg_normal = theme.color0
theme.fg_normal = theme.color7
theme.bg_focus = theme.color8
theme.fg_focus = theme.color15
theme.font = "sans 11"

theme.border_radius = dpi(12)

theme.wallpaper =
string.format(
  "%s/Pictures/wallpaper/index",
  os.getenv("HOME"))
--}}}

-- @wibar{{{
theme.wibar_width = 42
theme.wibar_height = theme.wibar_width
--}}}

-- @assets{{{
theme.awesome_icon =
  recolor(icon"mdi/chevron-right.svg", theme.color7)
--}}}

-- @titlebar {{{
theme.titlebar_bg_focus = theme.color0

theme.titlebar_close_button_normal =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_normal_hover =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_normal_press =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_focus =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_focus_hover =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_focus_press =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)

theme.titlebar_minimize_button_normal =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_normal_hover =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_normal_press =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_focus =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_focus_hover =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_focus_press =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)

theme.titlebar_maximized_button_normal_inactive =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_inactive_hover =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_inactive_press =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_focus_inactive =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_focus_inactive_hover =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_focus_inactive_press =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)

theme.titlebar_maximized_button_normal_active =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.titlebar_maximized_button_normal_active_hover =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.titlebar_maximized_button_normal_active_press =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.titlebar_maximized_button_focus_active =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.titlebar_maximized_button_focus_active_hover =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.titlebar_maximized_button_focus_active_press =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)

theme.titlebar_floating_button_normal_inactive = icon"floating-inactive.svg"
theme.titlebar_floating_button_normal_inactive_hover = icon"floating-inactive-hover.svg"
theme.titlebar_floating_button_normal_inactive_press = icon"floating-inactive-press.svg"
theme.titlebar_floating_button_focus_inactive = icon"floating-inactive.svg"
theme.titlebar_floating_button_focus_inactive_hover = icon"floating-inactive-hover.svg"
theme.titlebar_floating_button_focus_inactive_press = icon"floating-inactive-press.svg"
theme.titlebar_floating_button_normal_active = icon"floating-active.svg"
theme.titlebar_floating_button_normal_active_hover = icon"floating-active-hover.svg"
theme.titlebar_floating_button_normal_active_press = icon"floating-active-press.svg"
theme.titlebar_floating_button_focus_active = icon"floating-active.svg"
theme.titlebar_floating_button_focus_active_hover = icon"floating-active-hover.svg"
theme.titlebar_floating_button_focus_active_press = icon"floating-active-press.svg"
--}}}

-- layout icons{{{
theme.layout_max =
  recolor(icon"mdi/window-maximize.svg", theme.fg_focus)
theme.layout_floating =
  recolor(icon"mdi/window-restore.svg", theme.fg_focus)
theme.layout_tile =
  recolor(icon"mdi/view-quilt.svg", theme.fg_focus)
--
--}}}

-- menubar{{{
theme.menu_width = dpi(192)
theme.menu_height = theme.wibar_width
theme.menu_submenu_icon =
  recolor(icon"mdi/chevron-right.svg", theme.color7)
theme.menu_bg_normal = theme.color0
theme.menu_fg_focus = theme.color7
theme.menu_bg_focus = theme.color8
--}}}

-- client shape{{{
local rounded_rect_shape = function(cr,w,h)
    gears.shape.rounded_rect(cr, w, h, theme.border_radius)
end
client.connect_signal("manage", function(c)
    c.shape = rounded_rect_shape
end)
--}}}

-- tasklist{{{
theme.tasklist_bg_focus = theme.color10
theme.tasklist_bg_focus2 = theme.color0
theme.tasklist_thumbnail_outline = theme.color15
theme.tasklist_thumbnail_shape = rounded_rect_shape
--}}}

return theme
