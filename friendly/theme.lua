local beautiful = require("beautiful")
local theme_assets = require("beautiful.theme_assets")
dpi = require("beautiful.xresources").apply_dpi

beautiful.font = 'Latin Modern Sans 13'
beautiful.wibar_height = dpi(36)

beautiful.bg_normal = '#32323D'
beautiful.bg_focus  = '#87fcf9'
beautiful.fg_focus = "#ffffff"


beautiful.titlebar_bg_focus  = "#32323DD3"
beautiful.titlebar_bg_normal = beautiful.titlebar_bg_focus
beautiful.titlebar_fg_focus  = "#ffffff"
beautiful.titlebar_fg_normal = colormix(beautiful.bg_normal, beautiful.fg_focus, 0.5)
beautiful.titlebar_height    = beautiful.wibar_height

beautiful.border_normal = beautiful.titlebar_bg_normal
beautiful.border_focus  = beautiful.titlebar_bg_focus
beautiful.borbar_width  = dpi(3)

beautiful.menu_width  = dpi(256)
beautiful.menu_height = beautiful.wibar_height
beautiful.menu_bg_focus = colormix(beautiful.bg_normal, beautiful.bg_focus, 0.8) .. "D3"
beautiful.menu_fg_normal = '#e3e4e5'
beautiful.menu_fg_focus = '#3c3c46D3'
beautiful.menu_fg_focus = colorcontrast(beautiful.menu_bg_focus)

beautiful.tasklist_bg_focus = colormix(beautiful.bg_normal, beautiful.bg_focus, 0.8) .. "D3"
beautiful.tasklist_fg_focus = colorcontrast(beautiful.tasklist_bg_focus)


beautiful.awesome_icon = theme_assets.awesome_icon(table.unpack{
    beautiful.menu_height,
    beautiful.menu_bg_focus,
    beautiful.menu_fg_focus,
})
