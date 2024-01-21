local awful = require("awful")
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
local shape = require("myown.shape")
local im = require("images")

local function hex2rgb(cs)
	local reg = "[a-fA-F0-9]"
	local pad = "F"
	-- 6 because longest rgb format '#RGBA' format has 5 chars
	-- shortest rrggbb 'RRGGBB' format has 6 chars
	if #cs >= 6 then
		reg = "[a-fA-F0-9][a-fA-F0-9]"
		pad = ""
	end
	local chan = cs:gmatch(reg)
	local r = tonumber("0x" .. chan() .. pad)
	local g = tonumber("0x" .. chan() .. pad)
	local b = tonumber("0x" .. chan() .. pad)
	local a = chan()
	if a then
		a = tonumber("0x" .. a .. pad)
	else
		a = 255
	end
	return r, g, b, a
end

local function rgb2hex(r, g, b, a)
	local r = math.floor(r + 0.5)
	local g = math.floor(g + 0.5)
	local b = math.floor(b + 0.5)
	local s = "#" .. string.format("%02x", r) .. string.format("%02x", g) .. string.format("%02x", b)
	if a then
		s = s .. string.format("%02x", a)
	end
	return s
end

local function darken(c, rate)
	local r, g, b = hex2rgb(c)
	-- mix a dark variant by
	-- (color * 255 + back * 55) / (255 + 55)
	-- since black is 0, the code is reduced to this
	local rdark = r * 0.5
	local gdark = g * 0.5
	local bdark = b * 0.5
	r = r * (1 - rate) + rdark * rate
	g = g * (1 - rate) + gdark * rate
	b = b * (1 - rate) + bdark * rate
	return rgb2hex(r, g, b)
end

local function lighten(c, rate)
	local r, g, b = hex2rgb(c)
	c = rgb2hex(255 - r, 255 - g, 255 - b)
	r, g, b = hex2rgb(c)
	c = darken(c, rate)
	r, g, b = hex2rgb(c)
	return rgb2hex(255 - r, 255 - g, 255 - b)
end

local function draw(drawfn, w, h, color)
	w = w or 128
	h = h or w or 128
	local s = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
	local cr = cairo.Context(s)
	drawfn(cr, w, h)
	if color then
		cr:set_source(gcolor(color))
		cr:fill()
	end
	return s
end

function drawshape(shape, color)
	return draw(shape, nil, nil, color)
end


--[[ PASTEL ]]

theme.background       = "#2c2c2c"
theme.foreground       = "#dcdccc"
theme.color0           = "#3f3f3f"
theme.color8           = "#709080"
theme.color1           = "#705050"
theme.color9           = "#dca3a3"
theme.color2           = "#60b48a"
theme.color10          = "#72d5a3"
theme.color3           = "#dfaf8f"
theme.color11          = "#f0dfaf"
theme.color4           = "#9ab8d7"
theme.color12          = "#94bff3"
theme.color5           = "#dc8cc3"
theme.color13          = "#ec93d3"
theme.color6           = "#8cd0d3"
theme.color14          = "#93e0e3"
theme.color7           = "#dcdccc"
theme.color15          = "#ffffff"
theme.background_light = lighten(theme.background, 0.5)
theme.background_dark  = darken(theme.background, 0.9)
theme.foreground_light = lighten(theme.foreground, 0.9)
theme.foreground_dark  = darken(theme.foreground, 0.9)


--[[ BASIC ]]
theme.fontsize = dpi(gtk.font_size)
theme.font = gtk.font_family .. " " .. theme.fontsize
theme.bg_normal = theme.background_dark
theme.bg_focus = theme.background_light
theme.fg_normal = theme.foreground_dark
theme.fg_focus = theme.foreground_light
theme.icon_theme = "Papirus"


-- --[[ WIBAR ]]
theme.wibar_bg = theme.background_dark


-- -- [[SYSTEM TRAY]]
theme.bg_systray = theme.background


-- --[[ TASK LIST]]
theme.tasklist_fg_focus = "#FFF"
theme.tasklist_fg_normal = darken(theme.tasklist_fg_focus, 0.3)
theme.tasklist_bg_normal = gears.color.transparent
theme.tasklist_bg_focus = theme.tasklist_bg_normal
theme.tasklist_font_focus = theme.gtk.bold_font


-- --[[ NOTIFICATION ]]
-- theme.notification_bg = gtk.osd_bg_color
-- theme.notification_bg = gtk.osd_bg_color


--[[ BORDER ]]
theme.border_focus = theme.wibar_bg
theme.border_normal = theme.wibar_bg
theme.border_width = 3
theme.useless_gap = 3


--[[ MENU ]]
theme.menu_width = dpi(320)
theme.menu_height = dpi(32)
theme.menu_bg_normal = theme.bg_normal
theme.menu_bg_focus = theme.color2
theme.menu_fg_normal = theme.fg_normal
theme.menu_fg_focus = theme.fg_focus
-- theme.menu_border_color = theme.selected_bg_color
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
	cr:set_source(gears.color(theme.menu_fg_normal or theme.fg_normal))
	cr:fill()
end)


-- -- [[ TITLEBAR ]]
theme.titlebar_bg_normal = theme.wibar_bg
theme.titlebar_bg_focus = theme.wibar_bg
theme.titlebar_fg_focus = theme.foreground
theme.titlebar_fg_normal = theme.foreground_dark
theme.tbs1 = function(cr, w, h)
	cr:translate(w/2, h/2)
	cr:scale(0.5, 0.5)
	cr:translate(-w/2, -h/2)
	cr:move_to(0, h)
	cr:line_to(w/2, 0)
	cr:line_to(w, h)
	cr:close_path()
end
theme.tbs2 = function(cr, w, h)
	cr:translate(w/2, h/2)
	cr:scale(0.5, 0.5)
	cr:translate(-w/2, -h/2)
	cr:move_to(0, 0)
	cr:line_to(w/2, h)
	cr:line_to(w, 0)
	cr:close_path()
end
local function iic(name) return gcolor.recolor_image(im(name), theme.fg_normal) end
local function aic(name) return gcolor.recolor_image(im(name), theme.fg_focus) end
local empty_image = draw(function(...) end, 1, 1)

theme.titlebar_close_button_normal              = iic("close.svg")
theme.titlebar_close_button_focus               = aic("close.svg")
theme.titlebar_maximized_button_normal_inactive = empty_image
theme.titlebar_maximized_button_focus_inactive  = empty_image
theme.titlebar_maximized_button_normal_active   = iic("zoom-out-map.svg")
theme.titlebar_maximized_button_focus_active    = aic("zoom-out-map.svg")
theme.titlebar_ontop_button_normal_inactive     = empty_image
theme.titlebar_ontop_button_focus_inactive      = empty_image
theme.titlebar_ontop_button_normal_active       = iic("vertical-align-top.svg")
theme.titlebar_ontop_button_focus_active        = aic("vertical-align-top.svg")
theme.titlebar_sticky_button_normal_inactive    = empty_image
theme.titlebar_sticky_button_focus_inactive     = empty_image
theme.titlebar_sticky_button_normal_active      = iic("push-pin.svg")
theme.titlebar_sticky_button_focus_active       = aic("push-pin.svg")
theme.titlebar_floating_button_normal_inactive  = empty_image
theme.titlebar_floating_button_focus_inactive   = empty_image
theme.titlebar_floating_button_normal_active    = iic("layers.svg")
theme.titlebar_floating_button_focus_active     = aic("layers.svg")

theme.client_shape = function(cr, w, h)
	shape.rounded_rect(cr, w, h, 5)
end

client.connect_signal("tagged", function(c)
	if not c.icon then
		local s = gears.surface(im"console.png")
		s = gears.color.recolor_image(s, theme.titlebar_fg_focus)
		c.icon = s._native
	end
end)

theme.titlebar_setup = function(c)
	local layout = require("wibox.layout")
	local widget = require("wibox.widget")
	local container = require("wibox.container")
	local margin = 5

	-- indicator like style, only appears when you need to turn it off
	local indicator_wrap = function(name)
		local w = awful.titlebar.widget[name .. "button"](c)
		w = container.margin(w, 0, 0, margin, margin)
		w.visible = c[name]
		c:connect_signal("property::" .. name, function()
			w.visible = c[name]
		end)
		return w
	end

	-- setting up titlebar
	local buttons = {
		awful.button({}, 1, function() awful.mouse.client.move(c) end),
		awful.button({}, 2, function() myown.client.reset(c) end),
		awful.button({}, 3, function() awful.mouse.client.resize(c) end),
	}
	buttons = gears.table.join((unpack or table.unpack)(buttons))
	awful.titlebar(c, {position = "top"}):setup {
		layout = layout.align.horizontal,
		{
			widget = container.margin,
			margins = 5,
			{
				widget = container.background,
				shape = shape.squircle,
				bg = theme.color0,
				{
					widget = container.margin,
					margins = 2,
					awful.widget.clienticon(c),
				},
			},
		},
		{
			widget = container.place,
			buttons = buttons,
			awful.titlebar.widget.titlewidget(c),
		},
		{
			layout = layout.fixed.horizontal,
			indicator_wrap("maximized"),
			indicator_wrap("floating"),
			indicator_wrap("sticky"),
			indicator_wrap("ontop"),
			{
				widget = container.margin,
				top = margin,
				bottom = margin,
				right = margin,
				awful.titlebar.widget.closebutton(c),
			}
		}
	}
end


-- --[[ TAGLIST ]]
theme.taglist_bg_focus = theme.background
theme.taglist_fg_focus = theme.foreground_light
theme.taglist_bg_normal = beautiful.wibar_bg
theme.taglist_fg_normal = theme.foreground_dark

-- --[[ MENUBAR ]]
-- theme.menubar_bg_normal = theme.wibar_bg
-- theme.menubar_bg_focus = "#2c2c2c"
-- theme.menubar_fg_normal = darken("#FFF", 0.8)
-- theme.menubar_fg_focus = "#FFF"

-- --[[ LAYOUT ICONS ]]
theme.layout_floating = aic("layers.svg")
theme.layout_max = aic("zoom-out-map.svg")
theme.layout_tile = aic("grid-view.svg")


--[[ LAYOUTBOX ]]
theme.layoutbox_bg = theme.background

--[[ progress bar ]]
theme.progressbar_bg = theme.background
theme.progressbar_fg = theme.color2
return theme
