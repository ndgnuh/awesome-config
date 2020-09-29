local beautiful = require("beautiful")
local gears = require("gears")
local transparent = "#FFFFFF00"
local dpi = require"beautiful.xresources".apply_dpi

local fontbase = 'sans'
beautiful.font = fontbase .. '11'
beautiful.boldfont = fontbase .. ' 11'
beautiful.boldfontsmall = fontbase .. ' 9'
beautiful.icon_dir = debug.getinfo(1).source:sub(2):match("(.*/)") .. "/icons/"
beautiful.font = beautiful.boldfont
beautiful.fonts = {
   normal = "Segoe UI ",
   bold = "Segoe UI bold "
}
-------------------------------------------------
--  everything shaped this way in the game ui  --
-------------------------------------------------
beautiful.common_shape = function(r)
   return function(cr, w, h)
      local mr = r/2.5
      cr:arc(r, r, r, math.pi, 3*math.pi/2)
      cr:arc(w-mr, mr, mr, 3*math.pi/2, 0)
      -- cr:line_to(w, 0)
      cr:arc(w-r, h-r, r, math.pi*2 , math.pi/2)
      cr:arc(mr, h-mr, mr, math.pi/2, math.pi)
      -- cr:line_to(0, h)
      cr:line_to(0, r)
      cr:close_path()
   end
end

-------------------------
--  color from ggz ui  --
-------------------------
beautiful.blue = '#34A1DF'
beautiful.white = '#F3F4F5'
beautiful.yellow = '#FFD35C'
beautiful.orange = '#F19408'
beautiful.shade = '#212121b3'
beautiful.bg_normal = beautiful.white
beautiful.bg_focus = beautiful.white
beautiful.fg_normal = beautiful.blue
beautiful.fg_focus = beautiful.blue

----------------
--  titlebar  --
----------------
beautiful.titlebar_bg_normal = beautiful.shade
beautiful.titlebar_fg_normal = beautiful.white
beautiful.titlebar_bg_focus = beautiful.white
beautiful.titlebar_fg_focus = beautiful.blue
beautiful.titlebar_font = beautiful.boldfont
beautiful.titlebar_close_button_normal = beautiful.icon_dir .. "close.png"
beautiful.titlebar_close_button_normal_hover = beautiful.icon_dir .. "close.png"
beautiful.titlebar_close_button_normal_press = beautiful.icon_dir .. "close.png"
beautiful.titlebar_close_button_focus = beautiful.icon_dir .. "close.png"
beautiful.titlebar_close_button_focus_hover = gears.color.recolor_image(beautiful.icon_dir .. "close.png", beautiful.white .. "71")
beautiful.titlebar_close_button_focus_press = gears.color.recolor_image(beautiful.icon_dir .. "close.png", beautiful.white .. "b3")

----------------
--  tasklist  --
----------------
beautiful.tasklist_bg_normal = beautiful.shade
beautiful.tasklist_fg_normal = beautiful.white
beautiful.tasklist_bg_focus = beautiful.white
beautiful.tasklist_fg_focus = beautiful.blue
beautiful.tasklist_shape = beautiful.common_shape(dpi(8))
beautiful.tasklist_shape_border_color = beautiful.white
beautiful.tasklist_shape_border_width = dpi(2)

---------------------------
--  spacing and borders  --
---------------------------
beautiful.useless_gap = dpi(4)
beautiful.border_width = dpi(4)
beautiful.border_normal = beautiful.shade
beautiful.border_focus = beautiful.blue

-----------------------
--   wibar theming   --
-----------------------
beautiful.wibar_bg = gears.color.transparent
beautiful.wibar_height = dpi(64)
beautiful.wibar_border_width = dpi(2)
beautiful.wibar_border_color = nil

------------
--  menu  --
------------
beautiful.menu_bg_normal = beautiful.white
beautiful.menu_fg_normal = "#212121"
beautiful.menu_bg_focus = beautiful.blue
beautiful.menu_fg_focus = beautiful.white
beautiful.menu_border_width = dpi(8)
beautiful.menu_border_color = beautiful.white
beautiful.menu_height = dpi(32)
beautiful.menu_width = dpi(256)


-----------------------------
--  taglist as ui buttons  --
-----------------------------
beautiful.tags                       = {"Web", "Term", "Doc", "Media", "Extra"}
beautiful.taglist_font               = "Segoe UI Bold 11"
beautiful.taglist_fg_empty           = beautiful.white
beautiful.taglist_fg_urgent          = beautiful.white
beautiful.taglist_fg_occupied        = beautiful.white
beautiful.taglist_fg_focus           = beautiful.blue
beautiful.taglist_fg_volatile        = beautiful.white
beautiful.taglist_bg_empty           = beautiful.shade
beautiful.taglist_bg_urgent          = beautiful.shade
beautiful.taglist_bg_occupied        = beautiful.shade
beautiful.taglist_bg_focus           = beautiful.white
beautiful.taglist_bg_volatile        = beautiful.shade
beautiful.taglist_shape              = beautiful.common_shape(dpi(16))
beautiful.taglist_shape_border_width = dpi(2)
beautiful.taglist_shape_border_color = beautiful.blue .. 'b3'
-- beautiful.taglist_shape_border_color_focus = beautiful.white .. 'b3'
beautiful.taglist_spacing            = dpi(16)
beautiful.taglist_border_width       = dpi(2)
beautiful.taglist_border_color       = beautiful.white
beautiful.taglist_icon               = {
   Term  = beautiful.icon_dir .. 'term.png',
   Web   = beautiful.icon_dir .. 'web.png',
   Doc   = beautiful.icon_dir .. 'doc.png',
   Media = beautiful.icon_dir .. 'media.png',
   Extra = beautiful.icon_dir .. 'extra.png',
}

------------
--  tray  --
------------
beautiful.bg_systray = beautiful.shade
beautiful.systray_icon_spacing = dpi(4)

---------------------
--  hotkeys popup  --
---------------------
beautiful.hotkeys_font             = beautiful.font
beautiful.hotkeys_description_font = beautiful.hotkeys_font
beautiful.hotkeys_bg               = beautiful.white
beautiful.hotkeys_fg               = beautiful.shade
beautiful.hotkeys_modifiers_fg     = beautiful.blue
beautiful.hotkeys_border_width     = dpi(2)
beautiful.hotkeys_border_color     = beautiful.blue
beautiful.hotkeys_shape            = beautiful.common_shape(dpi(16))
beautiful.hotkeys_group_margin     = dpi(4)

-------------------
--  process bar  --
-------------------
beautiful.progressbar_fg = beautiful.blue
beautiful.progressbar_bg = beautiful.shade
beautiful.progressbar_margins = dpi(4)

----------------------
--  awesome assets  --
----------------------
beautiful.awesome_icon = beautiful.theme_assets.awesome_icon(
   beautiful.menu_height*2/3,
   beautiful.blue,
   beautiful.white
) -- awesome icon

beautiful.taglist_squares_sel = beautiful.theme_assets.taglist_squares_sel(
   dpi(4),
   beautiful.blue
)
beautiful.taglist_squares_unsel = beautiful.theme_assets.taglist_squares_unsel(
   dpi(4),
   beautiful.blue
)

------------------------
--  markup functions  --
------------------------
function beautiful.colortext(s, c)
   return "<span color='" .. c .. "'>".. tostring(s) .."</span>"
end

function beautiful.whitetext(txt)
   return beautiful.colortext(txt, beautiful.white)
end

function beautiful.bluetext(txt)
   return beautiful.colortext(txt, beautiful.blue)
end

function beautiful.yellowtext(txt)
   return beautiful.colortext(txt, beautiful.yellow)
end

function beautiful.blacktext(txt)
   return beautiful.colortext(txt, beautiful.shade)
end

--------------------
--  layout icons  --
--------------------
local themes_path = os.getenv("HOME").."/.config/awesome/themes/"
beautiful.layout_fairh      = themes_path.."default/layouts/fairhw.png"
beautiful.layout_fairv      = themes_path.."default/layouts/fairvw.png"
beautiful.layout_floating   = themes_path.."default/layouts/floatingw.png"
beautiful.layout_magnifier  = themes_path.."default/layouts/magnifierw.png"
beautiful.layout_max        = themes_path.."default/layouts/maxw.png"
beautiful.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
beautiful.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
beautiful.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
beautiful.layout_tile       = themes_path.."default/layouts/tilew.png"
beautiful.layout_tiletop    = themes_path.."default/layouts/tiletopw.png"
beautiful.layout_spiral     = themes_path.."default/layouts/spiralw.png"
beautiful.layout_dwindle    = themes_path.."default/layouts/dwindlew.png"
beautiful.layout_cornernw   = themes_path.."default/layouts/cornernww.png"
beautiful.layout_cornerne   = themes_path.."default/layouts/cornernew.png"
beautiful.layout_cornersw   = themes_path.."default/layouts/cornersww.png"
beautiful.layout_cornerse   = themes_path.."default/layouts/cornersew.png"

------------------
--  prompt box  --
------------------
beautiful.prompt_bg = gears.color.transparent
beautiful.prompt_fg = beautiful.shade
beautiful.prompt_fg_cursor = beautiful.white
beautiful.prompt_bg_cursor = beautiful.prompt_fg
beautiful.prompt_selected_bg = beautiful.blue
beautiful.prompt_selected_fg = beautiful.white
beautiful.prompt_prompt_fg = beautiful.shade
beautiful.prompt_prompt_bg = beautiful.white
beautiful.prompt_margins = dpi(8)
beautiful.prompt_wibox_margins = dpi(8)
-- beautiful.prompt_wibox_bg = beautiful.shade
-- beautiful.prompt_wibox_shape = beautiful.common_shape(dpi(16))
-- beautiful.prompt_wibox_border_width = dpi(2)
-- beautiful.prompt_wibox_border_color = beautiful.shade
beautiful.prompt_normal_fg = {
   beautiful.shade
}
beautiful.prompt_normal_bg = {
   "#dedede",
   beautiful.white
}

----------------
--  calendar  --
----------------
beautiful.calendar_style = {
   border_width = 0,
   padding = dpi(16)
}
beautiful.calendar_focus_shape = beautiful.common_shape(dpi(8))
beautiful.calendar_focus_border_width = dpi(4)
beautiful.calendar_focus_border_color = beautiful.blue
beautiful.calendar_focus_bg_color = beautiful.blue
beautiful.calendar_focus_fg_color = beautiful.white
beautiful.calendar_weekday_fg_color = beautiful.shade
beautiful.calendar_header_fg_color = beautiful.shade
