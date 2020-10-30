local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local common = require("common")
local beautiful = require("beautiful")
local partial = require("Partial")
local Rice = require("Rice")
local upower = require("model.upower")
local awesome = awesome
local client = client
local root = root

local db = require("Debug")

local dpi = beautiful.xresources.apply_dpi
do
  beautiful.font = "sans 12"
  beautiful.bg_normal = "#cecece"
  beautiful.fg_normal = "#1d1f21"
  beautiful.bg_focus = "#fefefe"
  beautiful.fg_focus = "#1d1f21"

  beautiful.wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper/index"

  beautiful.wibar_bg = "#bebebe"
  beautiful.wibar_width = dpi(32)
  beautiful.wibar_height = dpi(32)

  beautiful.tasklist_bg_normal = "#cecece"
  beautiful.tasklist_fg_normal = "#999999"
  beautiful.tasklist_bg_focus = "#fefefe"
  beautiful.tasklist_fg_focus = "#1d1f21"

  beautiful.titlebar_fg_normal = "#999999"
  beautiful.titlebar_fg_focus = "#1d1f21"

  beautiful.border_width = dpi(2)
  beautiful.border_focus = "#1d1f21"
  beautiful.border_normal = "#999999"

  beautiful.menu_bg_normal = "#fefefe"
  beautiful.menu_fg_normal = "#1d1f21"
  beautiful.menu_border_width = 0
  beautiful.menu_width = dpi(220)
  beautiful.menu_height = beautiful.wibar_height
  beautiful.menu_bg_focus = "#2367be"
  beautiful.menu_fg_focus = "#fefefe"
end

require("awful.autofocus")

local menu = awful.menu
{ items =
  { { "awesome"
    , { { "restart", awesome.restart }
      , { "quit", function() awesome.quit() end }
      }
    }
  , { "power"
    , { { "poweroff", "systemctl poweroff" }
      , { "restart", "systemctl restart" }
      , { "hibernate", "systemctl hibernate" }
      , { "suspend", "systemctl suspend" }
      }
    }
  , Rice.menu
  , { "Refresh", awesome.restart }
  , { "terminal", "x-terminal-emulator" }
  }
}

local set_wallpaper = function(s)
  local wallpaper = beautiful.wallpaper
  if type(wallpaper) == "string" then
    gears.wallpaper.maximized(wallpaper, s, true)
  else
    wallpaper(s)
  end
end

screen.connect_signal("request::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- set wallpaper when screen size changes
  set_wallpaper(s)

  awful.tag({1}, s, awful.layout.suit.max)

  s.topbar = awful.wibar {
    screen = s
    , position = "top"
  }

  -- tasklist{{{
  local tasklist_template = {
    widget = wibox.container.background
    , id = 'background_role'
    , {
      layout = wibox.layout.align.horizontal
      , forced_height = beautiful.wibar_height
      -- client icon
      , {
        widget = wibox.container.margin
        , forced_width = dpi(35)
        , margins = dpi(4)
        , {
          widget = awful.widget.clienticon
          , id = 'client_icon'
        }
      }
      -- client title
      , {
        widget = wibox.container.margin
        , margins = dpi(8)
        , {
          widget = wibox.widget.textbox
          , id = 'text_role'
          , align = 'left'
        }
      }
      -- close button
      , {
        widget = wibox.container.background
        , id = 'kill_button_hover_box'
        , {
          widget = wibox.container.margin
          , id = 'kill_button_clickbox'
          , margins = dpi(8)
          , {
            widget = wibox.container.place
            , forced_width = dpi(20)
            , {
              widget = wibox.widget.textbox
              , markup = "×"
              , id = 'kill_button'
            }
          }
        }
      }
    }
    , create_callback = function(self, c, index, object)
      local kill_button_clickbox = self:get_children_by_id("kill_button_clickbox")[1]
      kill_button_clickbox:connect_signal("button::press", function()
        c:kill()
      end)
      -- kill button hover box
      local kbhb = self:get_children_by_id("kill_button_hover_box")[1]
      kbhb:connect_signal("mouse::enter", function(self)
        self.bg = "#00000010"
      end)
      kbhb:connect_signal("mouse::leave", function(self)
        self.bg = gears.color.transparent
      end)

      self:get_children_by_id("client_icon")[1].client = c
    end
    , update_callback = function(self, c, index, object)
      local kill_button = self:get_children_by_id("kill_button")[1]
      if client.focus == c then
        kill_button.markup = string.format("<span color='%s'>x</span>", beautiful.tasklist_fg_focus)
      else
        kill_button.markup = string.format("<span color='%s'>x</span>", beautiful.tasklist_fg_normal)
      end
    end
  }
  do
    local buttons = gears.table.join
    ( awful.button({}, 1, function(c)
        if client.focus == c and not c.minimized then
          c.minimized = true
        else
          c:emit_signal("request::activate", "tasklist_click", {raise=true})
        end
      end)
    , awful.button({}, 3, function(c)
        c:kill()
      end)
    )

    s.tasklist = awful.widget.tasklist
    { screen = s
    , filter = function(...)
        return awful.widget.tasklist.filter.currenttags(...) and not awful.widget.tasklist.filter.minimizedcurrenttags(...)
      end
    , buttons = buttons
    , layout =
      { layout = wibox.layout.flex.horizontal
      , spacing = dpi(8)
      }
    , widget_template = tasklist_template
    }
  end--}}}

  -- hidden client list{{{
  do
    local popup = awful.popup
    { hide_on_right_click = true
    , visible = false
    , ontop = true
    , widget = awful.widget.tasklist
      { screen = s
      , layout = { layout = wibox.layout.fixed.vertical }
      , filter = awful.widget.tasklist.filter.minimizedcurrenttags
      , buttons = awful.button({}, 1, function(c)
          c:emit_signal("request::activate", "hidden_client", {raise = true})
        end)
      , widget_template = tasklist_template
      }
    }
    s.hidden_client = wibox.widget
    { widget = wibox.container.background
    , bg = beautiful.bg_focus
    , { widget = wibox.widget.textbox
      , text = " [H] "
      }
    }
    -- # bind to widget
    -- popup:bind_to_widget(s.topbar, 1)

    s.hidden_client:buttons(awful.button({}, 1, function()
      popup.visible = true
      popup.ontop = true
      -- popup:move_next_to(mouse.current_widget_geometry)
      awful.placement.under_mouse(popup)
      -- popup._private.show_fct()
      -- db.dump(123)
    end))
  end
  --}}}

  s.topbar:setup
  { layout = wibox.layout.align.horizontal
  , { layout = wibox.layout.fixed.horizontal
    , spacing = dpi(4)
    , s.hidden_client
    , s.tasklist
    }
  , nil
  , wibox.widget.textbox(os.getenv("USER") .. "@" .. tostring(io.popen("hostname"):read()))
  }

  -- battery widget{{{
  do
    s.battery = wibox.widget.textbox("")
    local update_function = function()
      s.battery.markup = "BAT: " .. tostring(upower:percentage())
    end
    update_function()
    upower.watch(update_function)
  end
  --}}}

  s.floating_bar = awful.popup{
    visible = true
    , ontop = true
    , border_color = "#1d1f21"
    , border_width = dpi(1)
    , widget = wibox.widget.textbox("")
    , shape = gears.shape.rounded_rect
    , bg = "#fefefe"
    , widget = wibox.widget {
      widget = wibox.container.margin
      , left = dpi(6)
      , right = dpi(6)
      , {
        layout = wibox.layout.fixed.horizontal
        , forced_height = beautiful.wibar_height
        , spacing_widget = wibox.widget{
          widget = wibox.container.margin
          , left = dpi(4)
          , right = dpi(4)
          , {
            widget = wibox.widget.separator
            , shape = gears.shape.circle
          }
        }
        , spacing = dpi(12)
        , require("common.ibus-indicator")
        , s.battery
        , wibox.widget.textclock("%H:%M")
        , {
          widget = wibox.widget.textbox
          , text = "⊕"
          , id = "mover"
        }
      }
    }
  }
  do
    local mover = s.floating_bar.widget:get_children_by_id("mover")[1]
    local off = beautiful.wibar_height / 2
    local placement =  {
      awful.placement.bottom_right
      , awful.placement.bottom_left
    }
    local place = 1
    local offset = {
      { x = -off, y = -off }
      , { x = off, y = -off }
    }
    mover:connect_signal("mouse::enter", function(self)
      place = place + 1
      if place > #offset then
        place = 1
      end
      placement[place](s.floating_bar, {offset = offset[place]})
    end)
    local adjust = function()
      placement[place](s.floating_bar, {offset = offset[place]})
    end
    s.floating_bar:connect_signal("property::height", adjust)
    s.floating_bar:connect_signal("property::width", adjust)
  end
end)

local titlebar = {}
titlebar.dialog = function(c)
  local buttons = gears.table.join(
    awful.button({}, 1, function() awful.mouse.client.move(c) end)
  , awful.button({}, 3, function() awful.mouse.client.resize(c) end)
  )
  local b = awful.titlebar(c, {size = beautiful.wibar_height})

  b:setup
  { layout = wibox.container.place
  , nil
  , awful.titlebar.widget.titlewidget(c)
  , buttons = buttons
  }
end
titlebar.normal = titlebar.dialog
client.connect_signal("request::titlebars", function(c)
  if c.type then
    if (c.type == "normal" and c.floating) or c.type ~= "normal" then
      local ttb = titlebar[c.type]
      if ttb then
        ttb(c)
      end
    end
  end
end)

common.dispatches["app/menu"] = function() menu:show() end
common:setup("w")

local setfloating = function(c)
  if not c.floating then
    c.border_width = 0
  else
    c.border_width = beautiful.border_width
  end
end
client.connect_signal("focus", function(c)
  setfloating(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  setfloating(c)
  c.border_color = beautiful.border_normal
end)
client.connect_signal("property::floating", setfloating)
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse::enter", {raise = false})
end)

do
  local keys = root.keys()
  local modkey = "Mod4"
  root.keys(gears.table.join(keys
  , awful.key({modkey}, "b", function()
      local s = awful.screen.focused()
      s.floating_bar.visible = not s.floating_bar.visible
    end, { description = "Toggle floating bar", group = "Misc" })
  ))
end
