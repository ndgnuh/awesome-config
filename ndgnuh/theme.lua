local beautiful = require("beautiful")
local apply_dpi = require("beautiful.xresources").apply_dpi
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local gshape = require("gears.shape")
local theme = { apply_dpi = apply_dpi }

--- Get resource from configuration directory
--- @param path string: resource path relative to the configuration directory
--- @return string: absolute path to resource
local resource = function(path)
    return gfs.get_configuration_dir() .. path
end

--- Get icon resource and recolor if needed
--- @param path string: icon path relative to configuration directory
--- @param color string: hex color string, if is nil, the icon won't be recolored
--- @return string: recolored icon
local icon = function(path, color)
    local ic = resource(path)
    if color then
        return gcolor.recolor_image(ic, color)
    else
        return ic
    end
end

-- [[ base settings ]]
-- use color from https://materialui.co/flatuicolors
theme.font = resource("assets/fonts/montserrat/Montserrat-Bold.ttf") .. " 11"
theme.bg_normal = "#2C3E50"
theme.bg_focus = "#3498DB"
theme.fg_normal = "#BDC3C7"
theme.fg_focus = "#ECF0F1"
theme.border_width = apply_dpi(1)
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.useless_gap = apply_dpi(4)
local font_height = beautiful.get_font_height(theme.font)

-- [[ wibar setup ]]
theme.wibar_width = font_height * 1.5
theme.wibar_height = font_height * 1.5

-- [[ taglist ]]
theme.taglist_bg_focus = theme.bg_focus
theme.taglist_bg_occupied = theme.bg_normal

-- [[ tasklist ]]
theme.tasklist_bg_focus = theme.bg_focus
theme.tasklist_bg_normal = gcolor.transparent
theme.tasklist_fg_focus = theme.fg_focus
theme.tasklist_fg_normal = theme.fg_focus
theme.tasklist_bg_minimize = gcolor.transparent
theme.tasklist_fg_minimize = "#34495E"

-- [[ Menu ]]
theme.menu_width = font_height * 13
theme.menu_height = font_height * 1.5
theme.menu_submenu_icon = icon("assets/icons/arrow_right.svg", theme.fg_focus)

-- [[ icons ]]
theme.layout_tile = icon("assets/icons/bento.svg", theme.fg_focus)
theme.layout_max = icon("assets/icons/fullscreen.svg", theme.fg_focus)
theme.layout_floating = icon("assets/icons/layers.svg", theme.fg_focus)
theme.awesome_icon = icon("assets/icons/auto_awesome.svg", theme.fg_focus)

-- [[ Notification ]]
theme.notification_font = resource("assets/fonts/Montserrat/static/Montserrat-Italic.ttf 14")
theme.notification_bg = "#9B59B6"
theme.notification_fg = theme.fg_focus
theme.notification_border_color  = "#8E44AD"
theme.notification_shape = gshape.rounded_rect
theme.notification_margin = font_height * 4.75
theme.notification_max_width = font_height * 32

return theme
