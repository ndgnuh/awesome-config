local dpi = require("beautiful.xresources").apply_dpi
local getenv = os.getenv
local theme = {}

theme.fontsize = dpi(11)
theme.primary = "#2367be"
theme.font = "monospace " .. theme.fontsize
theme.wallpaper = getenv("HOME") .. "/Pictures/wallpaper/index"
theme.wibar_width = theme.fontsize * 1.5
theme.wibar_height = theme.fontsize * 3.1415
theme.border_width = dpi(1)
theme.menu_border_width = 0
theme.menu_width = dpi(220)
theme.menu_height = theme.wibar_height

return theme
