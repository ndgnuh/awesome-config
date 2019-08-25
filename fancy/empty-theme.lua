local dpi = require("beautiful.xresources").apply_dpi
local draw = require("draw")
local shape = require("gears.shape")
local gtable = require("gears.table")
local color = require("gears.color")
local theme = {}
local wibar_size = dpi(32)

-- {{
-- local function, mostly for icon and stuff
local function titlebar_icon(bg)
   return draw(function(cr, w, h)
      cr:set_source(color(bg))
      cr:move_to(w/2,0)
      cr:line_to(w, h/2)
      cr:line_to(w/2, h)
      cr:line_to(0, h/2)
      cr:close_path()
      cr:fill()
   end)
end
local function ic(name)
   return theme.icondir .. name
end
-- }}

-- {{
-- non standard theme variables
-- }}
function theme.closure(f)
   return f()
end
theme.icondir = os.getenv("HOME") .. "/.config/awesome/fancy/icons/"
theme.blue = '#34A1DF'
theme.blue4 = '#34A1DF'
theme.blue3 = '#2298dd'
theme.blue2 = '#1f89c7'
theme.blue1 = '#1c7ab0'
theme.white = '#F3F4F5'
theme.white4 = '#F3F4F5'
theme.white3 = '#e4e4e4'
theme.white2 = '#d5d5d5'
theme.white1 = '#c6c6c6'
theme.yellow4 = '#FFFF8D'
theme.yellow3 = '#FFFF00'
theme.yellow2 = '#FFEA00'
theme.yellow1 = '#FFD600'
theme.orange = '#F19408'
theme.grey = '#232332'
theme.grey4 = "#3b3b4a"
theme.grey3 = "#333342"
theme.grey2 = "#2b2b3a"
theme.grey1 = "#232332"
theme.red4 = "#EB8181"
theme.red3 = "#E37979"
theme.red2 = "#DB7171"
theme.red1 = "#D36969"
theme.prompt_item_bg_selected = theme.blue

-- {{
-- standard variables
-- }}
theme.arcchart_border_color = nil
theme.arcchart_border_width = nil
theme.arcchart_color = nil
theme.arcchart_paddings = nil
theme.arcchart_thickness = nil
theme.awesome_icon = theme.icondir .. "round.png"
theme.bg_focus = theme.grey
theme.bg_minimize = theme.bg_focus
theme.bg_normal = theme.bg_focus
theme.bg_systray = "#2e344021"
theme.bg_urgent = theme.bg_focus
theme.border_focus = nil
theme.border_marked = nil
theme.border_normal = nil
theme.border_width = dpi(1)
theme.calendar_font = nil
theme.calendar_long_weekdays = nil
theme.calendar_spacing = nil
theme.calendar_start_sunday = nil
theme.calendar_style = nil
theme.calendar_week_numbers = nil
theme.checkbox_bg = nil
theme.checkbox_border_color = nil
theme.checkbox_border_width = nil
theme.checkbox_check_border_color = nil
theme.checkbox_check_border_width = nil
theme.checkbox_check_color = nil
theme.checkbox_check_shape = nil
theme.checkbox_color = nil
theme.checkbox_paddings = nil
theme.checkbox_shape = nil
theme.fg_focus = "#ffffff"
theme.fg_minimize = "#616161"
theme.fg_normal = theme.fg_focus
theme.fg_urgent = theme.fg_minimize
theme.font = "Input Sans Bold 11"
theme.graph_bg = nil
theme.graph_border_color = nil
theme.graph_fg = nil
theme.hotkeys_bg = nil
theme.hotkeys_border_color = nil
theme.hotkeys_border_width = nil
theme.hotkeys_description_font = nil
theme.hotkeys_fg = nil
theme.hotkeys_font = nil
theme.hotkeys_group_margin = nil
theme.hotkeys_label_bg = nil
theme.hotkeys_label_fg = nil
theme.hotkeys_modifiers_fg = nil
theme.hotkeys_shape = nil
theme.icon_theme = nil
theme.layout_cornerne = nil
theme.layout_cornernw = nil
theme.layout_cornerse = nil
theme.layout_cornersw = nil
theme.layout_dwindle = nil
theme.layout_fairh = ic("tile.svg")
theme.layout_fairv = ic("tile.svg")
theme.layout_floating = draw(function(cr, w, h)
   cr:set_source(color(theme.white1))
   cr:rectangle(w/3, h/3, 2*w/3, 2*h/3)
   cr:fill()
   cr:set_source(color(theme.white4))
   cr:rectangle(0, 0, 2*w/3, 2*h/3)
   cr:fill()
end, theme.iconsize, theme.iconsize)
theme.layout_fullscreen = nil
theme.layout_magnifier = nil
theme.layout_max = nil
theme.layout_spiral = nil
theme.layout_tile = draw(function(cr, w, h)
   local gaps = w / 8
   cr:set_source(color(theme.white4))
   cr:rectangle(0,0, w/2 - gaps/2, h)
   cr:fill()
   cr:set_source(color(theme.white3))
   cr:rectangle(w/2+gaps/2, 0, w/2 - gaps/2, h/2-gaps/2)
   cr:fill()
   cr:set_source(color(theme.white2))
   cr:rectangle(w/2+gaps/2, h/2+gaps/2, w/2 - gaps/2, h/2-gaps/2)
   cr:fill()
end)
theme.layout_tilebottom = nil
theme.layout_tileleft = nil
theme.layout_tiletop = nil
theme.layoutlist_align = nil
theme.layoutlist_bg_normal = nil
theme.layoutlist_bg_selected = nil
theme.layoutlist_disable_icon = nil
theme.layoutlist_disable_name = nil
theme.layoutlist_fg_normal = nil
theme.layoutlist_fg_selected = nil
theme.layoutlist_font = nil
theme.layoutlist_font_selected = nil
theme.layoutlist_shape = nil
theme.layoutlist_shape_border_color = nil
theme.layoutlist_shape_border_color_selected = nil
theme.layoutlist_shape_border_width = nil
theme.layoutlist_shape_border_width_selected = nil
theme.layoutlist_shape_selected = nil
theme.layoutlist_spacing = nil
theme.menu_width = dpi(256)
theme.menu_height = wibar_size
theme.menu_bg_focus = color{
   type = "linear",
   from = { 0, 0 },
   to = { theme.menu_width, 0 },
   stops = {
      { 0.25, theme.blue1 },
      { 0.50, theme.blue2 },
      { 0.75, theme.blue3 },
      { 0.99, theme.blue4 },
   }
}
theme.menu_bg_normal = color{
   type = "linear",
   from = { 0, 0 },
   to = { theme.menu_width, 0 },
   stops = {
      { 0.25, theme.grey1 },
      { 0.50, theme.grey2 },
      { 0.75, theme.grey3 },
      { 0.99, theme.grey4 },
   }
}
theme.menu_border_color = nil
theme.menu_border_width = nil
theme.menu_fg_focus = nil
theme.menu_fg_normal = nil
theme.menu_font = nil
theme.menu_submenu = nil
theme.menu_submenu_icon = nil
theme.menubar_bg_normal = nil
theme.menubar_border_color = nil
theme.menubar_border_width = nil
theme.menubar_fg_normal = nil
theme.notification_action_bg_normal = nil
theme.notification_action_bg_selected = nil
theme.notification_action_bgimage_normal = nil
theme.notification_action_bgimage_selected = nil
theme.notification_action_fg_normal = nil
theme.notification_action_fg_selected = nil
theme.notification_action_icon_only = nil
theme.notification_action_icon_size_normal = nil
theme.notification_action_icon_size_selected = nil
theme.notification_action_label_only = nil
theme.notification_action_shape_border_color_normal = nil
theme.notification_action_shape_border_color_selected = nil
theme.notification_action_shape_border_width_normal = nil
theme.notification_action_shape_border_width_selected = nil
theme.notification_action_shape_normal = nil
theme.notification_action_shape_selected = nil
theme.notification_action_underline_normal = nil
theme.notification_action_underline_selected = nil
theme.notification_bg_normal = theme.grey1
theme.notification_bg_selected = theme.blue1
theme.notification_bgimage_normal = nil
theme.notification_bgimage_selected = nil
theme.notification_fg_normal = nil
theme.notification_fg_selected = nil
theme.notification_font = "Iosevka 12"
theme.notification_icon_size_normal = dpi(64)
theme.notification_icon_size_selected = dpi(64)
theme.notification_max_width = nil
theme.notification_width = dpi(512)
theme.notification_max_height = dpi(1024)
theme.notification_position = nil
theme.notification_shape_border_color_normal = nil
theme.notification_shape_border_color_selected = nil
theme.notification_shape_border_width_normal = nil
theme.notification_shape_border_width_selected = nil
theme.notification_shape_normal = nil
theme.notification_shape_selected = nil
theme.piechart_border_color = nil
theme.piechart_border_width = nil
theme.piechart_colors = nil
theme.progressbar_bar_border_color = nil
theme.progressbar_bar_border_width = nil
theme.progressbar_bar_shape = nil
theme.progressbar_bg = nil
theme.progressbar_border_color = nil
theme.progressbar_border_width = nil
theme.progressbar_fg = nil
theme.progressbar_margins = nil
theme.progressbar_paddings = nil
theme.progressbar_shape = nil
theme.prompt_bg = nil
theme.prompt_fg = nil
theme.radialprogressbar_border_color = nil
theme.radialprogressbar_border_width = nil
theme.radialprogressbar_color = nil
theme.radialprogressbar_paddings = nil
theme.separator_border_color = nil
theme.separator_border_width = nil
theme.separator_color = nil
theme.separator_shape = nil
theme.separator_span_ratio = nil
theme.separator_thickness = nil
theme.slider_bar_active_color = nil
theme.slider_bar_border_color = nil
theme.slider_bar_border_width = nil
theme.slider_bar_color = nil
theme.slider_bar_height = nil
theme.slider_bar_margins = nil
theme.slider_bar_shape = nil
theme.slider_handle_border_color = nil
theme.slider_handle_border_width = nil
theme.slider_handle_margins = nil
theme.slider_handle_shape = nil
theme.slider_handle_width = nil
theme.systray_icon_spacing = nil
theme.taglist_bg_empty = nil
theme.taglist_bg_focus = theme.blue4
theme.taglist_bg_occupied = theme.blue1
theme.taglist_bg_urgent = theme.red1
theme.taglist_bg_volatile = nil
theme.taglist_disable_icon = nil
theme.taglist_fg_empty = nil
theme.taglist_fg_focus = theme.grey3
theme.taglist_fg_occupied = theme.grey1
theme.taglist_fg_urgent = nil
theme.taglist_fg_volatile = nil
theme.taglist_font = nil
theme.taglist_shape = function(cr, w, h)
   cr:move_to(w/2, 0)
   cr:line_to(w, h/2)
   cr:line_to(w/2, h)
   cr:line_to(0, h/2)
   cr:close_path()
end
theme.taglist_shape_border_color = nil
theme.taglist_shape_border_color_empty = nil
theme.taglist_shape_border_color_focus = nil
theme.taglist_shape_border_color_urgent = nil
theme.taglist_shape_border_color_volatile = nil
theme.taglist_shape_border_width = nil
theme.taglist_shape_border_width_empty = nil
theme.taglist_shape_border_width_focus = nil
theme.taglist_shape_border_width_urgent = nil
theme.taglist_shape_border_width_volatile = nil
theme.taglist_shape_empty = nil
theme.taglist_shape_focus = nil
theme.taglist_shape_urgent = nil
theme.taglist_shape_volatile = nil
theme.taglist_spacing = dpi(8)
theme.taglist_squares_resize = nil
theme.taglist_squares_sel = nil
theme.taglist_squares_sel_empty = nil
theme.taglist_squares_unsel = nil
theme.taglist_squares_unsel_empty = nil
theme.tasklist_align = "left"
theme.tasklist_bg_focus = theme.grey4
theme.tasklist_bg_image_focus = nil
theme.tasklist_bg_image_minimize = nil
theme.tasklist_bg_image_normal = nil
theme.tasklist_bg_image_urgent = nil
theme.tasklist_bg_minimize = theme.grey1
theme.tasklist_bg_normal = theme.tasklist_bg_minimize
theme.tasklist_bg_urgent = nil
theme.tasklist_disable_icon = nil
theme.tasklist_disable_task_name = nil
theme.tasklist_fg_focus = nil
theme.tasklist_fg_minimize = theme.white4
theme.tasklist_fg_normal = theme.white4
theme.tasklist_fg_urgent = nil
theme.tasklist_font = nil
theme.tasklist_font_focus = nil
theme.tasklist_font_minimized = nil
theme.tasklist_font_urgent = nil
theme.tasklist_plain_task_name = nil
theme.tasklist_shape = nil
theme.tasklist_shape_border_color = nil
theme.tasklist_shape_border_color_focus = nil
theme.tasklist_shape_border_color_minimized = nil
theme.tasklist_shape_border_color_urgent = nil
theme.tasklist_shape_border_width = nil
theme.tasklist_shape_border_width_focus = nil
theme.tasklist_shape_border_width_minimized = nil
theme.tasklist_shape_border_width_urgent = nil
theme.tasklist_shape_focus = nil
theme.tasklist_shape_minimized = nil
theme.tasklist_shape_urgent = nil
theme.tasklist_spacing = dpi(8)
theme.titlebar_bg = nil
theme.titlebar_bg_focus = nil
theme.titlebar_bg_normal = nil
theme.titlebar_bgimage = nil
theme.titlebar_bgimage_focus = nil
theme.titlebar_bgimage_normal = nil
theme.titlebar_close_button_focus = titlebar_icon(theme.red1)
theme.titlebar_close_button_focus_hover = titlebar_icon(theme.red3)
theme.titlebar_close_button_focus_press = titlebar_icon(theme.red4)
theme.titlebar_close_button_normal = titlebar_icon(theme.white1)
theme.titlebar_close_button_normal_hover = titlebar_icon(theme.white1)
theme.titlebar_close_button_normal_press = titlebar_icon(theme.white1)
theme.titlebar_fg = nil
theme.titlebar_fg_focus = nil
theme.titlebar_fg_normal = "#919191"
theme.titlebar_floating_button_focus = nil
theme.titlebar_floating_button_focus_active = nil
theme.titlebar_floating_button_focus_active_hover = nil
theme.titlebar_floating_button_focus_active_press = nil
theme.titlebar_floating_button_focus_inactive = nil
theme.titlebar_floating_button_focus_inactive_hover = nil
theme.titlebar_floating_button_focus_inactive_press = nil
theme.titlebar_floating_button_normal = nil
theme.titlebar_floating_button_normal_active = nil
theme.titlebar_floating_button_normal_active_hover = nil
theme.titlebar_floating_button_normal_active_press = nil
theme.titlebar_floating_button_normal_inactive = nil
theme.titlebar_floating_button_normal_inactive_hover = nil
theme.titlebar_floating_button_normal_inactive_press = nil
theme.titlebar_maximized_button_focus = ic("maximize.svg")
theme.titlebar_maximized_button_focus_active = ic("maximize.svg")
theme.titlebar_maximized_button_focus_active_hover = ic("maximize.svg")
theme.titlebar_maximized_button_focus_active_press = ic("maximize.svg")
theme.titlebar_maximized_button_focus_inactive = ic("maximize.svg")
theme.titlebar_maximized_button_focus_inactive_hover = ic("maximize.svg")
theme.titlebar_maximized_button_focus_inactive_press = ic("maximize.svg")
theme.titlebar_maximized_button_normal = nil
theme.titlebar_maximized_button_normal_active = nil
theme.titlebar_maximized_button_normal_active_hover = nil
theme.titlebar_maximized_button_normal_active_press = nil
theme.titlebar_maximized_button_normal_inactive = nil
theme.titlebar_maximized_button_normal_inactive_hover = nil
theme.titlebar_maximized_button_normal_inactive_press = nil
theme.titlebar_minimize_button_focus = titlebar_icon(theme.yellow1)
theme.titlebar_minimize_button_focus_hover = titlebar_icon(theme.yellow3)
theme.titlebar_minimize_button_focus_press = titlebar_icon(theme.yellow4)
theme.titlebar_minimize_button_normal = titlebar_icon(theme.white1)
theme.titlebar_minimize_button_normal_hover = titlebar_icon(theme.white1)
theme.titlebar_minimize_button_normal_press = titlebar_icon(theme.white1)
theme.titlebar_ontop_button_focus = titlebar_icon(theme.blue4)
theme.titlebar_ontop_button_focus_active = titlebar_icon(theme.blue4)
theme.titlebar_ontop_button_focus_active_hover = nil
theme.titlebar_ontop_button_focus_active_press = nil
theme.titlebar_ontop_button_focus_inactive = titlebar_icon(theme.blue1)
theme.titlebar_ontop_button_focus_inactive_hover = nil
theme.titlebar_ontop_button_focus_inactive_press = nil
theme.titlebar_ontop_button_normal = nil
theme.titlebar_ontop_button_normal_active = titlebar_icon(theme.white1)
theme.titlebar_ontop_button_normal_active_hover = nil
theme.titlebar_ontop_button_normal_active_press = nil
theme.titlebar_ontop_button_normal_inactive = titlebar_icon(theme.white1)
theme.titlebar_ontop_button_normal_inactive_hover = nil
theme.titlebar_ontop_button_normal_inactive_press = nil
theme.titlebar_sticky_button_focus = nil
theme.titlebar_sticky_button_focus_active = nil
theme.titlebar_sticky_button_focus_active_hover = nil
theme.titlebar_sticky_button_focus_active_press = nil
theme.titlebar_sticky_button_focus_inactive = nil
theme.titlebar_sticky_button_focus_inactive_hover = nil
theme.titlebar_sticky_button_focus_inactive_press = nil
theme.titlebar_sticky_button_normal = nil
theme.titlebar_sticky_button_normal_active = nil
theme.titlebar_sticky_button_normal_active_hover = nil
theme.titlebar_sticky_button_normal_active_press = nil
theme.titlebar_sticky_button_normal_inactive = nil
theme.titlebar_sticky_button_normal_inactive_hover = nil
theme.titlebar_sticky_button_normal_inactive_press = nil
theme.tooltip_align = nil
theme.tooltip_bg = nil
theme.tooltip_border_color = nil
theme.tooltip_border_width = nil
theme.tooltip_fg = nil
theme.tooltip_font = nil
theme.tooltip_opacity = nil
theme.tooltip_shape = nil
theme.useless_gap = nil
theme.wallpaper = "~/Pictures/wallpaper"
theme.wibar_bg = nil
theme.wibar_bgimage = nil
theme.wibar_border_color = nil
theme.wibar_border_width = nil
theme.wibar_cursor = nil
theme.wibar_fg = nil
theme.wibar_height = wibar_size
theme.wibar_ontop = nil
theme.wibar_opacity = nil
theme.wibar_shape = nil
theme.wibar_stretch = true
theme.wibar_type = nil
theme.wibar_width = wibar_size
return theme
