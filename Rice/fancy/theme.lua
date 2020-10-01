local gears = require("gears")
local recolor = gears.color.recolor_image
local dpi = require("theme.xresources").apply_dpi
local theme = {}

theme.font = 'Input Sans Regular 11'
theme.boldfont = 'Input Sans Bold 11'
theme.boldfontsmall = 'Input Sans Bold 9'
theme.icon_dir = os.getenv("HOME") .. "/.config/awesome/fancy/icons/"

-------------
--  color  --
-------------
theme.blue = '#34A1DF'
theme.white = '#F3F4F5'
theme.yellow = '#FFD35C'
theme.orange = '#F19408'
theme.shade = '#212121b3'
theme.bg_normal = "#232424"
theme.bg_focus = "#232430"
theme.fg_normal = theme.white
theme.fg_focus = theme.white

----------------
--  titlebar  --
----------------
local round = theme.icon_dir .. "round.png"
theme.titlebar_bg_normal = "#232430"
theme.titlebar_fg_normal = "#616161"
theme.titlebar_bg_focus = "#232430"
theme.titlebar_fg_focus = theme.white
theme.titlebar_font = theme.boldfont
theme.titlebar_close_button_normal = recolor(round, theme.titlebar_fg_normal)
theme.titlebar_minimize_button_normal = recolor(round, theme.titlebar_fg_normal)
theme.titlebar_close_button_normal_hover = recolor(round, theme.blue)
theme.titlebar_close_button_normal_press = recolor(round, theme.blue)
theme.titlebar_close_button_focus = recolor(round, theme.blue)
theme.titlebar_close_button_focus_hover = recolor(recolor(round, theme.blue), theme.white .. "61")
theme.titlebar_close_button_focus_press = recolor(recolor(round, theme.blue), theme.white .. "91")
theme.titlebar_minimize_button_focus = recolor(round, theme.yellow)
theme.titlebar_minimize_button_focus_hover = recolor(recolor(round, theme.yellow), theme.white .. "61")
theme.titlebar_minimize_button_focus_press = recolor(recolor(round, theme.yellow), theme.white .. "91")

----------------
--  tasklist  --
----------------
theme.tasklist_bg_normal = nil
theme.tasklist_fg_normal = nil
theme.tasklist_bg_focus = theme.blue
theme.tasklist_fg_focus = nil
theme.tasklist_shape = nil
theme.tasklist_shape_border_color = nil
theme.tasklist_shape_border_width = nil

---------------------------
--  spacing and borders  --
---------------------------
theme.useless_gap = dpi(0)
theme.border_width = dpi(2)
theme.border_normal = theme.titlebar_bg_normal
theme.border_focus = theme.titlebar_bg_focus

-----------------------
--   wibar theming   --
-----------------------
theme.wibar_bg = theme.bg_normal
theme.wibar_width = dpi(32)
theme.wibar_height = theme.wibar_width
theme.wibar_border_width = dpi(0)
theme.wibar_border_color = nil
-- theme.wibar_shape = gears.shape.rounded_rect

------------
--  menu  --
------------
theme.menu_bg_normal = theme.white
theme.menu_fg_normal = "#212121"
theme.menu_bg_focus = theme.blue
theme.menu_fg_focus = theme.white
theme.menu_border_width = dpi(8)
theme.menu_border_color = theme.white
theme.menu_height = dpi(32)
theme.menu_width = dpi(256)


-----------------------------
--  taglist as ui buttons  --
-----------------------------
theme.tags                       = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
theme.taglist_font               = nil
theme.taglist_fg_empty           = nil
theme.taglist_fg_urgent          = nil
theme.taglist_fg_occupied        = theme.wibar_bg
theme.taglist_fg_focus           = theme.wibar_bg
theme.taglist_fg_volatile        = nil
theme.taglist_bg_empty           = nil
theme.taglist_bg_urgent          = nil
theme.taglist_bg_occupied        = theme.yellow
theme.taglist_bg_focus           = theme.blue
theme.taglist_bg_volatile        = nil
theme.taglist_shape              = gears.shape.circle
theme.taglist_shape_border_width = dpi(2)
theme.taglist_shape_border_color = theme.wibar_bg
-- theme.taglist_shape_border_color_focus = theme.white .. 'b3'
theme.taglist_spacing            = dpi(16)
theme.taglist_border_width       = dpi(2)

------------
--  tray  --
------------
theme.bg_systray = theme.shade
theme.systray_icon_spacing = dpi(4)

---------------------
--  hotkeys popup  --
---------------------
theme.hotkeys_font             = theme.font
theme.hotkeys_description_font = theme.hotkeys_font
theme.hotkeys_bg               = theme.white
theme.hotkeys_fg               = theme.shade
theme.hotkeys_modifiers_fg     = theme.blue
theme.hotkeys_border_width     = dpi(2)
theme.hotkeys_border_color     = theme.blue
theme.hotkeys_shape            = theme.common_shape(dpi(16))
theme.hotkeys_group_margin     = dpi(4)

-------------------
--  process bar  --
-------------------
theme.progressbar_fg = theme.blue
theme.progressbar_bg = theme.shade
theme.progressbar_margins = dpi(4)

----------------------
--  awesome assets  --
----------------------
theme.awesome_icon = theme.theme_assets.awesome_icon(
   theme.menu_height*2/3,
   theme.blue,
   theme.white
) -- awesome icon

theme.taglist_squares_sel = theme.theme_assets.taglist_squares_sel(
   dpi(4),
   theme.blue
)
theme.taglist_squares_unsel = theme.theme_assets.taglist_squares_unsel(
   dpi(4),
   theme.blue
)

------------------------
--  markup functions  --
------------------------
function theme.colortext(s, c)
   return "<span color='" .. c .. "'>".. tostring(s) .."</span>"
end

function theme.whitetext(txt)
   return theme.colortext(txt, theme.white)
end

function theme.bluetext(txt)
   return theme.colortext(txt, theme.blue)
end

function theme.yellowtext(txt)
   return theme.colortext(txt, theme.yellow)
end

function theme.blacktext(txt)
   return theme.colortext(txt, theme.shade)
end

--------------------
--  layout icons  --
--------------------
local themes_path = os.getenv("HOME").."/.config/awesome/themes/"
theme.layout_fairh      = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv      = themes_path.."default/layouts/fairvw.png"
theme.layout_floating   = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier  = themes_path.."default/layouts/magnifierw.png"
theme.layout_max        = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile       = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop    = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral     = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle    = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw   = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne   = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw   = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse   = themes_path.."default/layouts/cornersew.png"

------------------
--  prompt box  --
------------------
theme.prompt_bg = theme.blue
theme.prompt_fg = theme.white
theme.prompt_fg_cursor = theme.white
theme.prompt_bg_cursor = theme.prompt_fg
theme.prompt_selected_bg = theme.blue
theme.prompt_selected_fg = theme.white
theme.prompt_prompt_fg = theme.shade
theme.prompt_prompt_bg = theme.white
theme.prompt_margins = dpi(8)
theme.prompt_wibox_margins = dpi(8)
-- theme.prompt_wibox_bg = theme.shade
-- theme.prompt_wibox_shape = theme.common_shape(dpi(16))
-- theme.prompt_wibox_border_width = dpi(2)
-- theme.prompt_wibox_border_color = theme.shade
-- theme.prompt_normal_fg = {
--    theme.shade
-- }
-- theme.prompt_normal_bg = {
--    "#dedede",
--    theme.white
-- }

----------------
--  calendar  --
----------------
theme.calendar_style = {
   border_width = 0,
   padding = dpi(16)
}
theme.calendar_focus_shape = nil
theme.calendar_focus_border_width = dpi(4)
theme.calendar_focus_border_color = theme.blue
theme.calendar_focus_bg_color = theme.blue
theme.calendar_focus_fg_color = theme.white
theme.calendar_weekday_fg_color = theme.shade
theme.calendar_header_fg_color = theme.shade

--------------------
--  notification  --
--------------------
theme.notification_font = nil
theme.notification_bg = nil
theme.notification_fg = nil
theme.notification_border_width = nil
theme.notification_border_color = nil
theme.notification_shape = nil
theme.notification_opacity = nil
theme.notification_margin = nil
theme.notification_width = nil
theme.notification_height = nil
theme.notification_spacing = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
