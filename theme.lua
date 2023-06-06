local beautiful = require("beautiful")
local C = require("c_hybrid")
local theme = {}

theme.primary = C.color2
theme.bg_normal = C.background
theme.fg_normal = C.foreground
theme.bg_focus = C.color8
theme.fg_focus = C.color15

-- border
theme.border_width = 2
theme.border_focus = theme.bg_focus
theme.border_normal = theme.bg_normal

theme.master_width_factor = 0.55 -- learn from dwm guys
theme.font_size = 12
theme.font_size_px = theme.font_size * beautiful.xresources.get_dpi() / 72
theme.font = "sans " .. theme.font_size
theme.useless_gap = theme.font_size_px / 4
theme.menu_width = theme.font_size_px * 15
theme.menu_height = theme.wibar_height
theme.taglist_bg_focus = theme.primary
theme.taglist_bg_normal = theme.bg_normal
theme.taglist_bg_occupied = theme.bg_normal
theme.taglist_bg_empty = theme.bg_normal
theme.taglist_fg_focus = C.color0
theme.taglist_fg_occupied = C.foreground
theme.taglist_fg_empty = C.color7

-- wibar
theme.wibar_height = math.ceil(theme.font_size_px * 2)
theme.wibar_width = theme.wibar_height
theme.wibar_bg = C.background

-- tasklist
theme.tasklist_bg_focus = theme.primary
theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_fg_focus = C.color0
theme.tasklist_fg_normal = theme.fg_normal
theme.tasklist_fg_minimize = C.color7

return theme
