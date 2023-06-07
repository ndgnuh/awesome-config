local beautiful = require("beautiful")
local C = require("c_hybrid")
local theme = {colors = C}

theme.primary = C.color2
theme.bg_primary = C.color2
theme.fg_primary = C.color0
theme.bg_normal = C.background
theme.fg_normal = C.foreground
theme.bg_focus = C.color8
theme.fg_focus = C.color15

-- border
theme.border_width = 2
theme.border_focus = theme.bg_focus
theme.border_normal = theme.bg_normal

theme.master_width_factor = 0.55 -- learn from dwm guys
theme.font_size = 11
theme.font_size_px = theme.font_size * beautiful.xresources.get_dpi() / 72
theme.font = "sans " .. theme.font_size
theme.useless_gap = theme.font_size_px / 4
theme.taglist_bg_focus = theme.primary
theme.taglist_bg_normal = theme.bg_normal
theme.taglist_bg_occupied = theme.bg_normal
theme.taglist_bg_empty = theme.bg_normal
theme.taglist_fg_focus = C.color0
theme.taglist_fg_occupied = C.foreground
theme.taglist_fg_empty = C.color7

-- wibar
theme.wibar_height = math.ceil(theme.font_size_px * 2.5)
theme.wibar_width = theme.wibar_height
theme.wibar_bg = C.background

-- custom widget
theme.pill_margins = theme.wibar_width * 0.05
theme.pill_bg = theme.primary

-- menu
-- beautiful.menu_submenu_icon 	The icon used for sub-menus.
-- beautiful.menu_font 	The menu text font.
theme.menu_height = theme.wibar_height
theme.menu_width = theme.font_size_px * 18
theme.menu_border_color = theme.fg_primary
theme.menu_border_width = theme.border_width
theme.menu_fg_focus = theme.fg_primary
theme.menu_bg_focus = theme.bg_primary
theme.menu_fg_normal = theme.fg_normal
theme.menu_bg_normal = theme.bg_normal
-- theme.menu_submenu = ""

theme.bg_systray = theme.bg_focus

-- tasklist
theme.tasklist_bg_focus = theme.primary
theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_fg_focus = C.color0
theme.tasklist_fg_normal = theme.fg_normal
theme.tasklist_fg_minimize = C.color7

return theme
