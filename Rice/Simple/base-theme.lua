local dpi = require("beautiful.xresources").apply_dpi
local getenv = os.getenv
local theme = {}

theme.primary = "#2367be"
theme.font = "sans 14"
theme.wallpaper = getenv("HOME") .. "/Pictures/wallpaper/index"
theme.wibar_width = dpi(32)
theme.wibar_height = dpi(32)
theme.border_width = dpi(2)
theme.menu_border_width = 0
theme.menu_width = dpi(220)

return theme
