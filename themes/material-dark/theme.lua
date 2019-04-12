---------------------------------------------------------------------
-- Theme based on Google's Material guide line on dark theme       --
-- https://material.io/design/color/dark-theme.html#ui-application --
-- author: ndgnuh <ndgnuh99@gmail.com>				   --
---------------------------------------------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

-- global variable
theme.colors = {
	bg = "#21282f",
	accent = "#A5D6A7",
	active = "#84FFFF",
	high_contrast = "#e3e4e5",
	-- error = "#CF6679",
	disabled ="#616161",
}

theme.wallpaper = os.getenv("HOME") .. "/pictures/wallpaper.jpg"
theme.font = "Iosevka 11"
theme.bg_normal = theme.colors.bg
theme.bg_focus = "121212"
theme.fg_normal = "#e3e3e3"
theme.fg_focus = "#ffffff"
theme.fg_urgent = "#ff0000"

theme.useless_gap = dpi(4)
theme.border_width = dpi(1)
theme.border_normal = theme.bg_normal
theme.border_focus = "#84FFFF"

theme.titlebar_bg_focus = theme.colors.bg
theme.titlebar_fg_focus = theme.colors.active

return theme
