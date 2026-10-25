--- My custom theme
-- @module ndgnuh.theme
local beautiful = require("beautiful")
local apply_dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local gcolor = require("gears.color")
local gshape = require("gears.shape")
local theme = { apply_dpi = apply_dpi }
local naughty = require("naughty")
local icons = require("icons")
local resource = require("lib.resource")
local hsl = resource.hsl

local signals = require("lib.signals")

-- [[ Color settings ]]
-- background color
local bg_hue = 230
local bg_sat = 0.0

-- Hues
local e_hue = 0 -- error color
local w_hue = 47 -- warning color
local i_hue = 220 -- info color

-- [[ base settings ]]
-- use color from https://materialui.co/flatuicolors
theme.font = "sans " .. math.floor(apply_dpi(7))
theme.icon_theme = "Vimix"

-- SomeWM exclusive
theme.shadow_enabled = true
theme.shadow_radius = 6 -- Larger blur = softer
theme.shadow_opacity = 0.8 -- More transparent
theme.shadow_offset_x = 0.5 -- Spread further
theme.shadow_offset_y = 0.5

theme.shadow_color = "#C0392B"
theme.shadow_drawin_color = "#1d1f21"

theme.wallpaper = gears.filesystem.get_configuration_dir() .. "/assets/wallpaper-16-10.jpg"

theme.gutter = apply_dpi(8)
theme.gutter_small = theme.gutter / 2
theme.gutter_tiny = theme.gutter / 4
theme.gutter_large = theme.gutter * 2

-- background colors
theme.bg_lightest = hsl(bg_hue, bg_sat, 0.90)
theme.bg_lighter = hsl(bg_hue, bg_sat, 0.85)
theme.bg_light = hsl(bg_hue, bg_sat, 0.80)
theme.bg = hsl(bg_hue, bg_sat, 0.75)
theme.bg_dark = hsl(bg_hue, bg_sat, 0.70)
theme.bg_darker = hsl(bg_hue, bg_sat, 0.65)
theme.bg_darkest = hsl(bg_hue, bg_sat, 0.60)

theme.primary = "#B6321C"
theme.primary = "#685496" -- material you purple

-- [[ Standard awesome variables ]]
theme.bg_normal = resource.rgbf(0.15, 0.15, 0.16)
theme.bg_enter = theme.bg_light
theme.bg_press = theme.primary

theme.bg_focus = theme.bg_lightest
theme.bg_focus = theme.bg_lighter
theme.fg_normal = "#FEFCFF"
theme.fg_focus = theme.primary
theme.border_width = 0
theme.border_normal = "#FFFFFF"
theme.border_focus = theme.primary

theme.useless_gap = 10
theme.gap_single_client = true

theme.client_shape_bounding = gshape.rounded_rect
theme.client_shape_clip = gshape.rounded_rect
theme.shape_bounding = gshape.rounded_rect
theme.shape_clip = gshape.rounded_rect
theme.shape_input = gshape.rounded_rect

local font_height = beautiful.get_font_height(theme.font)

-- [[ wibar setup ]]
theme.wibar_width = font_height * 1.5
theme.wibar_height = theme.wibar_width
theme.wibar_bg = resource.rgbf(0.15, 0.15, 0.16) .. "EE"
theme.wibar_fg = theme.fg_normal
theme.wibar_spacing = theme.gutter
theme.wibar_border_width = 0
theme.wibar_width = theme.wibar_width - theme.wibar_spacing
theme.wibar_border_color = theme.wibar_bg

-- [[ taglist ]]
theme.taglist_bg_focus = theme.primary
theme.taglist_bg_occupied = theme.bg_normal

-- [[ tasklist ]]
theme.tasklist_bg_focus = theme.primary
theme.tasklist_bg_normal = hsl(0, 0, 0.8)
theme.tasklist_fg_focus = theme.primary
theme.tasklist_fg_normal = theme.wibar_fg
theme.tasklist_bg_minimize = gcolor.transparent
theme.tasklist_fg_minimize = hsl(bg_hue, 0.1, 0.25)

-- [[ widget: progressbar ]]
theme.progressbar_bg = "#E2E0F9"
theme.progressbar_fg = theme.primary
theme.progressbar_shape = gears.shape.rounded_rect

local alpha = "AE"

-- [[ Menu ]]
theme.menu_width = font_height * 15
theme.menu_height = font_height * 1.8
theme.menu_submenu_icon = icons.arrow_forward
theme.menu_border_width = 1
theme.menu_border_color = theme.primary
theme.menu_bg_normal = theme.bg_normal .. alpha
theme.menu_bg_focus = theme.primary .. alpha
theme.menu_fg_focus = theme.fg_normal

-- [[ icons ]]
theme.layout_tile = resource.icon("assets/icons/bento.svg", theme.fg_focus)
theme.layout_max = resource.icon("assets/icons/fullscreen.svg", theme.fg_focus)
theme.layout_floating = resource.icon("assets/icons/layers.svg", theme.fg_focus)
theme.awesome_icon = resource.icon("assets/icons/auto_awesome.svg", "#fff")
theme.os_icon = resource.icon("assets/icons/nix-os.svg")

-- [[ Notification ]]
theme.notification_font = resource.resource("assets/fonts/Montserrat/static/Montserrat-Italic.ttf 14")
theme.notification_bg = theme.bg_normal .. alpha
theme.notification_fg = theme.fg_normal
theme.notification_border_width = 1
theme.notification_border_color = theme.primary
theme.notification_shape = function(cr, w, h)
	gshape.rounded_rect(cr, w, h, theme.gutter)
end
theme.notification_margin = theme.gutter_large
theme.notification_icon_size = apply_dpi(48)
-- clay layout: box width, gap between boxes, offset from the screen edge
theme.notification_width = apply_dpi(380)
theme.notification_max_width = theme.notification_width
theme.notification_spacing = theme.gutter
theme.notification_padding = theme.useless_gap * 2

-- [[ tooltip ]]
theme.tooltip_bg = hsl(i_hue, 0.8, 0.7)
theme.tooltip_fg = hsl(i_hue, 0.5, 0.3)
theme.tooltip_border_width = apply_dpi(2)
theme.tooltip_border_color = theme.tooltip_fg
theme.tooltip_font = "Sans 14"
theme.tooltip_margin = apply_dpi(4)
-- theme.tooltip_shape = function(cr, w, h)
--     cr:move_to(0, 0)
--     cr:line_to(w, 0)
--     cr:line_to(w, h * .8)
--     cr:line_to(w, h * .8)
--     cr:line_to(0, h * .8)
--     cr:line_to(0, 0)
--     cr:close_path()
-- end
-- theme.tooltip_shape = function(cr, w, h)
--     local shape = gshape.transform(gshape.infobubble)
--     shape = shape:translate(w/2, h/2):rotate(90):translate(-w/2, -h/2)
--     shape(cr, w, h)
-- end

-- [[ Notification ]]

-- common theme var
local noti_border = apply_dpi(2)
local noti_margin = apply_dpi(16)

theme.notification_shape = gears.shape.rectangle
theme.notification_border_width = noti_border
theme.notification_bg = theme.bg_lighter
theme.notification_fg = theme.fg_focus
theme.notification_border_color = theme.bg_darker
theme.notification_margin = noti_margin

-- normal preset
naughty.config.defaults.border_width = noti_border
naughty.config.defaults.border_color = theme.bg_darker
naughty.config.defaults.margin = noti_margin
naughty.config.defaults.title = "Notice"

-- critical preset, for errors
naughty.config.presets.critical.title = "Critical"
naughty.config.presets.critical.fg = hsl(e_hue, 0.9, 0.3)
naughty.config.presets.critical.bg = hsl(e_hue, 0.7, 0.8)
naughty.config.presets.critical.timeout = 0
naughty.config.presets.critical.border_width = noti_border
naughty.config.presets.critical.border_color = naughty.config.presets.critical.fg

-- warning preset, for debugging and warning
naughty.config.presets.warn.title = "Warning"
naughty.config.presets.warn.fg = hsl(w_hue, 0.9, 0.3)
naughty.config.presets.warn.bg = hsl(w_hue, 0.7, 0.8)
naughty.config.presets.warn.border_width = noti_border
naughty.config.presets.warn.border_color = naughty.config.presets.warn.fg
naughty.config.presets.warn.margin = noti_margin

-- [[ Hot key popup ]]
theme.hotkeys_bg = theme.bg
theme.hotkeys_border_width = apply_dpi(2)
theme.hotkeys_border_color = theme.bg_darker
theme.hotkeys_label_bg = theme.primary
theme.hotkeys_label_fg = theme.fg_focus
theme.hotkeys_modifiers_fg = theme.bg_lightest
theme.hotkeys_group_margin = apply_dpi(18)

-- [[ tray ]]
theme.bg_systray = theme.wibar_bg
theme.systray_icon_spacing = theme.wibar_spacing

return theme
