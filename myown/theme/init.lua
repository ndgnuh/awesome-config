local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local gcolor = require("gears.color")
local cairo = require("lgi").cairo
local theme = {
	gtk = require("beautiful.gtk").get_theme_variables()
}
local gtk = theme.gtk

local function draw(drawfn, w, h)
	w = w or 128
	h = h or w or 128
	local s = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
	local cr = cairo.Context(s)
	drawfn(cr, w, h)
	return s
end


--[[ BASIC ]]
theme.fontsize = dpi(gtk.font_size)
theme.font = gtk.font_family .. " " .. theme.fontsize
theme.bg_normal = gtk.wm_bg_color
theme.bg_focus = gtk.selected_bg_color
theme.fg_normal = gtk.fg_color
theme.fg_focus = gtk.selected_fg_color
theme.icon_theme = "Papirus"


-- [[SYSTEM TRAY]]
theme.bg_systray = gtk.tooltip_fg_color


--[[ TASK LIST]]
theme.tasklist_fg_normal = theme.wibar_fg
theme.tasklist_bg_normal = theme.wibar_bg
theme.tasklist_fg_focus = theme.tasklist_fg_normal
theme.tasklist_bg_focus = theme.tasklist_bg_normal
theme.tasklist_font_focus = theme.gtk.bold_font


--[[ NOTIFICATION ]]
theme.notification_bg = gtk.osd_bg_color
theme.notification_bg = gtk.osd_bg_color


--[[ BORDER ]]
theme.border_focus = gtk.wm_border_focused_color
theme.border_normal = gtk.wm_border_unfocused_color
theme.border_width = dpi(gtk.button_border_width)


--[[ MENU ]]
theme.menu_width = dpi(320)
theme.menu_height = dpi(32)
theme.menu_bg_normal = gtk.menubar_bg_color
theme.menu_bg_focus = gtk.selected_bg_color
theme.menu_fg_normal = gtk.menubar_fg_color
theme.menu_fg_focus = gtk.selected_fg_color
theme.menu_border_color = theme.selected_bg_color
theme.menu_submenu_icon = draw(function(cr, w, h)
	local b = math.min(w, h) / math.pi
	cr:translate(w/2,h/2)
	cr:scale(0.5, 0.5)
	cr:translate(-w/2,-h/2)
	cr:move_to(w-2*b, 0)
	cr:line_to(w-b, 0)
	cr:line_to(w, h/2)
	cr:line_to(w-b, h)
	cr:line_to(w-2*b, h)
	cr:line_to(w-b, h/2)
	cr:close_path()
	cr:set_source(gears.color(theme.menu_fg_normal))
	cr:fill()
end)


-- [[ TITLEBAR ]]
theme.titlebar_bg_normal = gtk.wm_bg_color
theme.titlebar_bg_focus = gtk.wm_bg_color
theme.titlebar_fg_normal = theme.fg_normal
theme.titlebar_fg_focus = theme.fg_focus


--[[ TAGLIST ]]
theme.taglist_bg_focus = "#444"
theme.taglist_bg_normal = "#222"


--[[ LAYOUT ICONS ]]
-- theme.layout_cornerne
-- theme.layout_cornernw
-- theme.layout_cornerse
-- theme.layout_cornersw
-- theme.layout_dwindle
-- theme.layout_fairh
-- theme.layout_fairv
theme.layout_floating = draw(function(cr, w, h)
	local a, b = w/3, h/3
	cr:set_source(gcolor"#FFFFFF")
	cr:rectangle(0, 0, 2*a, 2*b)
	cr:rectangle(a, b, 2*a, 2*b)
	cr:fill()
end)
-- theme.layout_fullscreen
-- theme.layout_magnifier
theme.layout_max = draw(function(cr, w, h)
	local g = math.min(w, h) / 10
	cr:set_source(gcolor"#FFFFFF")
	cr:rectangle(0, 0, w, h)
	cr:fill()
	cr:rectangle(g, 2*g, w-2*g, h-3*g)
	cr:fill()
end)
-- theme.layout_spiral
theme.layout_tile = draw(function(cr, w, h)
	local a, b, g = w/2, h/2, math.min(w, h) / 25
	cr:set_source(gcolor"#FFFFFF")
	cr:rectangle(0, 0, a-g, b-g)
	cr:rectangle(0, b, a-g, b)
	cr:rectangle(a, 0, a, h)
	cr:fill()
end)
-- theme.layout_tilebottom
-- theme.layout_tileleft
-- theme.layout_tiletop


--[[ LAYOUTBOX ]]
theme.layoutbox_bg = gtk.selected_bg_color
return theme
