local beautiful = require("beautiful")
local gears = require("gears")
local transparent = "#FFFFFF00"

beautiful.font = 'Segoe UI 11'
beautiful.boldfont = 'Segoe UI Bold 11'
beautiful.boldfontsmall = 'Segoe UI Bold 9'
beautiful.icon_dir = os.getenv("HOME") .. "/.config/awesome/ggz/icons/"
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
beautiful.white = '#F3F4EF'
beautiful.yellow = '#F3C819'
beautiful.orange = '#F19408'
beautiful.shade = '#212121b3'
beautiful.bg_normal = beautiful.white
beautiful.bg_focus = beautiful.white
beautiful.fg_normal = beautiful.blue
beautiful.fg_focus = beautiful.blue

----------------
--  tasklist  --
----------------
beautiful.tasklist_bg_normal = beautiful.shade
beautiful.tasklist_fg_normal = beautiful.white
beautiful.tasklist_bg_focus = beautiful.blue
beautiful.tasklist_fg_focus = beautiful.white
beautiful.tasklist_shape = beautiful.common_shape(dpi(8))
beautiful.tasklist_shape_border_color = beautiful.white
beautiful.tasklist_shape_border_width = dpi(2)

---------------------------
--  spacing and borders  --
---------------------------
beautiful.useless_gap = dpi(4)
beautiful.border_width = dpi(2)

-----------------------
--   wibar theming   --
-----------------------
beautiful.wibar_bg = gears.color.transparent
beautiful.wibar_height = dpi(64)
beautiful.wibar_border_width = beautiful.useless_gap
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
   Term  = os.getenv("HOME") .. '/.config/awesome/ggz/icons/term.png',
   Web   = os.getenv("HOME") .. '/.config/awesome/ggz/icons/web.png',
   Doc   = os.getenv("HOME") .. '/.config/awesome/ggz/icons/doc.png',
   Media = os.getenv("HOME") .. '/.config/awesome/ggz/icons/media.png',
   Extra = os.getenv("HOME") .. '/.config/awesome/ggz/icons/extra.png',
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
   return "<span color='" .. c .. "'>".. s .."</span>"
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
