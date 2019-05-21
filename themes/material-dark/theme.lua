---------------------------------------------------------------------
-- Theme based on Google's Material guide line on dark theme       --
-- https://material.io/design/color/dark-theme.html#ui-application --
-- author: ndgnuh <ndgnuh99@gmail.com>				   --
---------------------------------------------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi
local gears        = require("gears")
local icons        = os.getenv("HOME") .. "/.config/awesome/themes/material-dark/icons/"
local theme        = {}

theme.wallpaper = os.getenv("HOME") .. "/pictures/wallpaper.jpg"
theme.font      = "Roboto 11"

theme.color_bg            = "#21282f"
theme.color_accent        = "#03A9F4"
theme.color_active        = "#40C4FF"
theme.color_active_fg     = "#21282f"
theme.color_high_contrast = "#f3f4f5"
theme.color_error         = "#CF6679"
theme.color_disabled      = "#616161"

theme.bg_normal = theme.color_bg
theme.bg_focus  = "121212"
theme.fg_normal = "#e3e3e3"
theme.fg_focus  = "#ffffff"
theme.fg_urgent = "#ff0000"

theme.useless_gap   = dpi(8)
theme.border_width  = dpi(2)
theme.border_normal = theme.color_bg
theme.border_focus  = theme.color_bg

theme.titlebar_bg_focus  = theme.color_active
theme.titlebar_bg_normal = theme.color_bg
theme.titlebar_fg_focus  = theme.color_active_fg
theme.titlebar_fg_normal = theme.color_high_contrast

theme.taglist_bg_focus       = theme.color_active
theme.taglist_bg_urgent      = theme.color_error
theme.taglist_bg_empty       = nil
theme.taglist_bg_volatile    = nil
theme.taglist_bg_occupied    = nil
theme.taglist_fg_focus       = theme.color_active_fg
theme.taglist_fg_urgent      = nil
theme.taglist_fg_empty       = theme.color_disabled
theme.taglist_fg_volatile    = nil
theme.taglist_fg_occupied    = nil
theme.taglist_shape_focus    = nil
theme.taglist_shape_urgent   = nil
theme.taglist_shape_empty    = nil
theme.taglist_shape_volatile = nil
theme.taglist_shape_occupied = nil
theme.taglist_fg_occupied    = nil
theme.taglist_spacing        = dpi(4)

theme.menu_height       = dpi(32)
theme.menu_width        = dpi(218)
theme.menu_border_color = nil
theme.menu_border_width = nil
theme.menu_fg_focus     = theme.color_active_fg
theme.menu_fg_normal    = nil
theme.menu_bg_focus     = theme.color_active
theme.menu_bg_normal    = nil

theme.notification_width          = dpi(512)
theme.notification_minimum_height = dpi(64)

theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.color_bg, theme.color_accent)

theme.layout_tile     = icons .. "tile.png"
theme.layout_floating = icons .. "floating.png"

theme.wibar_position = 'top'

return theme
