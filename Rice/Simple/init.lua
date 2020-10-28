local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local common = require("common")
local beautiful = require("beautiful")
local partial = require("Partial")
local Rice = require("Rice")
local awesome = awesome
local client = client
local root = root

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

  s.topbar = awful.wibar
  { screen = s
  , position = "top"
  }

  --s.leftbar = awful.wibar {
  --  position = "left",
  --  screen = s,
  --  stretch = true,
  --}

  -- tasklist{{{
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
    , filter = awful.widget.tasklist.filter.currenttags
    , buttons = buttons
    , layout =
      { layout = wibox.layout.flex.horizontal
      , spacing = dpi(8)
      }
    , widget_template =
      { widget = wibox.container.background
      , id = 'background_role'
      , { layout = wibox.layout.align.horizontal
        -- client icon
        , { widget = wibox.container.margin
          , forced_width = dpi(35)
          , margins = dpi(4)
          , { widget = awful.widget.clienticon
            , id = 'client_icon'
            }
          }
        -- client title
        , { widget = wibox.container.margin
          , margins = dpi(8)
          , { widget = wibox.widget.textbox
            , id = 'text_role'
            , align = 'left'
            }
          }
        -- close button
        , { widget = wibox.container.margin
          , id = 'kill_button_clickbox'
          , margins = dpi(8)
          , { widget = wibox.container.place
            , forced_width = dpi(20)
            , { widget = wibox.widget.textbox
              , markup = "x"
              , id = 'kill_button'
              }
            }
          }
        }
      , create_callback = function(self, c, index, object)
          local kill_button_clickbox = self:get_children_by_id("kill_button_clickbox")[1]
          kill_button_clickbox:connect_signal("button::press", function()
            c:kill()
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
    }
  end--}}}

  s.topbar:setup
  { layout = wibox.layout.align.horizontal
  , s.tasklist
  , nil
  , wibox.widget.textbox(os.getenv("USER") .. "@" .. tostring(io.popen("hostname"):read()))
  }

  -- s.leftbar:setup
  -- { layout = wibox.layout.align.vertical
  -- , { layout = wibox.layout.fixed.vertical
  --   , wibox.widget.textbox("")
  --   } -- left
  -- , nil -- middle
  -- , { layout = wibox.layout.fixed.vertical
  --   , { widget = wibox.container.place
  --     , wibox.widget.textclock("<tt>%H\n%M</tt>")
  --     }
  --   } -- right
  -- }
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
client.connect_signal("request::titlebars", function(c)
  if c.type then
    local ttb = titlebar[c.type]
    if ttb then
      ttb(c)
    end
  end
end)

-- root.buttons(gears.table.join(
--   awful.button({}, 3, function() menu:show() end)
-- ))

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
