-- requirements {{{
local icon = require"icon"
local gears = require"gears"
-- }}}

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
theme.color0 = "#1a1a1a"
theme.color1 = "#fb7e8e"
theme.color2 = "#52ba40"
theme.color3 = "#b0a800"
theme.color4 = "#5aaaf2"
theme.color5 = "#ee80c0"
theme.color6 = "#1db5c3"
theme.color7 = "#c4bdaf"
-- bright colors
theme.color8 = "#18143d"
theme.color9 = "#f69d6a"
theme.color10 = "#88c400"
theme.color11 = "#d7ae00"
theme.color12 = "#8cb4f0"
theme.color13 = "#de99f0"
theme.color14 = "#00ca9a"
theme.color15 = "#e0e0e0"
--}}}

-- standard variables {{{
theme.bg_normal = "#1a1a1a"
theme.fg_normal = "#e0e0e0"
theme.bg_normal = theme.color0
theme.fg_normal = theme.color7
theme.bg_focus = theme.color8
theme.fg_focus = theme.color15

theme.border_width = dpi(0)
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.font = "sans 11"

theme.border_radius = dpi(12)

theme.wallpaper =
string.format(
  "%s/Pictures/wallpaper/index",
  os.getenv("HOME"))
--}}}

-- non standard colors {{{
theme.cursorColor = "#e0e0e0"
theme.cursorColor2 = "#1a1a1a"
-- }}}

-- wibar{{{
theme.wibar_width = dpi(42)
theme.wibar_height = theme.wibar_width
--}}}

-- assets{{{
theme.awesome_icon =
  recolor(icon"mdi/chevron-right.svg", theme.color4)
--}}}

-- titlebar {{{
theme.titlebar_bg_focus = theme.color0

theme.titlebar_close_button_normal =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_normal_hover =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_normal_press =
  recolor(icon"mdi/close-thick.svg", theme.fg_normal)
theme.titlebar_close_button_focus =
  recolor(icon"mdi/close-thick.svg", theme.color1)
theme.titlebar_close_button_focus_hover =
  recolor(icon"mdi/close-thick.svg", theme.color9)
theme.titlebar_close_button_focus_press =
  recolor(icon"mdi/close-thick.svg", theme.color9)

theme.titlebar_minimize_button_normal =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_normal_hover =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_normal_press =
  recolor(icon"mdi/window-minimize.svg", theme.fg_normal)
theme.titlebar_minimize_button_focus =
  recolor(icon"mdi/window-minimize.svg", theme.color3)
theme.titlebar_minimize_button_focus_hover =
  recolor(icon"mdi/window-minimize.svg", theme.color3)
theme.titlebar_minimize_button_focus_press =
  recolor(icon"mdi/window-minimize.svg", theme.color11)

theme.titlebar_maximized_button_normal_inactive =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_inactive_hover =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_inactive_press =
  recolor(icon"mdi/window-restore.svg", theme.fg_normal)
theme.titlebar_maximized_button_focus_inactive =
  recolor(icon"mdi/window-restore.svg", theme.color4)
theme.titlebar_maximized_button_focus_inactive_hover =
  recolor(icon"mdi/window-restore.svg", theme.color12)
theme.titlebar_maximized_button_focus_inactive_press =
  recolor(icon"mdi/window-restore.svg", theme.color12)

theme.titlebar_maximized_button_normal_active =
  recolor(icon"mdi/window-maximize.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_active_hover =
  recolor(icon"mdi/window-maximize.svg", theme.fg_normal)
theme.titlebar_maximized_button_normal_active_press =
  recolor(icon"mdi/window-maximize.svg", theme.fg_normal)
theme.titlebar_maximized_button_focus_active =
  recolor(icon"mdi/window-maximize.svg", theme.color4)
theme.titlebar_maximized_button_focus_active_hover =
  recolor(icon"mdi/window-maximize.svg", theme.color4)
theme.titlebar_maximized_button_focus_active_press =
  recolor(icon"mdi/window-maximize.svg", theme.color12)

theme.titlebar_floating_button_normal_inactive =
  recolor(icon"mdi/view-quilt.svg", theme.fg_normal)
theme.titlebar_floating_button_normal_inactive_hover =
  recolor(icon"mdi/view-quilt.svg", theme.fg_normal)
theme.titlebar_floating_button_normal_inactive_press =
  recolor(icon"mdi/view-quilt.svg", theme.fg_normal)
theme.titlebar_floating_button_focus_inactive =
  recolor(icon"mdi/view-quilt.svg", theme.color2)
theme.titlebar_floating_button_focus_inactive_hover =
  recolor(icon"mdi/view-quilt.svg", theme.color2)
theme.titlebar_floating_button_focus_inactive_press =
  recolor(icon"mdi/view-quilt.svg", theme.color10)

theme.titlebar_floating_button_normal_active =
  recolor(icon"mdi/view-quilt-outline.svg", theme.fg_normal)
theme.titlebar_floating_button_normal_active_hover =
  recolor(icon"mdi/view-quilt-outline.svg", theme.fg_normal)
theme.titlebar_floating_button_normal_active_press =
  recolor(icon"mdi/view-quilt-outline.svg", theme.fg_normal)
theme.titlebar_floating_button_focus_active =
  recolor(icon"mdi/view-quilt-outline.svg", theme.color2)
theme.titlebar_floating_button_focus_active_hover =
  recolor(icon"mdi/view-quilt-outline.svg", theme.color2)
theme.titlebar_floating_button_focus_active_press =
  recolor(icon"mdi/view-quilt-outline.svg", theme.color10)
--}}}

-- layout icons{{{
theme.layout_max =
  recolor(icon"mdi/window-maximize.svg", theme.color4)
theme.layout_floating =
  recolor(icon"mdi/window-restore.svg", theme.color4)
theme.layout_tile =
  recolor(icon"mdi/view-quilt.svg", theme.color4)
theme.layout_fullscreen =
  recolor(icon"mdi/fullscreen.svg", theme.color4)
--}}}

-- menubar{{{
theme.menu_width = dpi(192)
theme.menu_height = theme.wibar_width
theme.menu_submenu = " ▸ "
-- theme.menu_submenu_icon =
-- recolor(icon"mdi/chevron-right.svg", theme.color7)
theme.menu_bg_normal = theme.color0
theme.menu_fg_focus = theme.color15
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
theme.tasklist_bg_focus = theme.color4
theme.tasklist_bg_focus2 = theme.color8
theme.tasklist_thumbnail_outline = theme.color3
theme.tasklist_thumbnail_shape = rounded_rect_shape
--}}}

-- battery widget color{{{
theme.battery_color_full = theme.color2
theme.battery_color_normal = theme.color4
theme.battery_color_low = theme.color1
--}}}

return theme
