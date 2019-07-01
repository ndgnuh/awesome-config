------------------------------------------------------------------------
--                  Config for awesome wm by ndgnuh                   --
------------------------------------------------------------------------
pcall(require, "luarocks,loader")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local menubar = require("menubar")
local popup_hotkeys = require("awful.hotkeys_popup")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
local api = require("api")
api.audio.set_step(5)

-------------------
--  some config  --
-------------------
ign = os.getenv("USER") .. "@ArchBtw" -- this will be displayed on the info panel
iglevel = 373 -- this will be displayed on the info panel

------------------------------------------------------------------------
--                           theming stuffs                           --
------------------------------------------------------------------------
-- beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
require("ggz.theme")
beautiful.wallpaper = beautiful.icon_dir .. "wallpaper.png"

------------------------------------------------------------------------
--                           custom widgets                           --
------------------------------------------------------------------------
local ggz_layoutbox = require("ggz.widgets.layoutbox")
require("ggz.mediapopup")
require("ggz.widgets.tasklist")
require("ggz.widgets.taglist")
require("ggz.widgets.info")

------------------------------------------------------------------------
--                          auto start stuff                          --
------------------------------------------------------------------------
awful.spawn.once("xrandr --output HDMI1 --left-of eDP1")
awful.spawn.once("compton")


------------------------------------------------------------------------
--                            handle error                            --
------------------------------------------------------------------------
if awesome.startup_errors then
   naughty.notification {
      preset  = naughty.config.presets.critical,
      title   = "Oops, there were errors during startup!",
      message = awesome.startup_errors
   }
end

do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
      if in_error then
         return true
      end
      in_error = true
      naughty.notification({
         preset = naughty.config.presets.critical,
         title = "Unknown error has occured",
         message = tostring(err)
      })
   end)
end


------------------------------------------------------------------------
--                 some global variables and configs                  --
------------------------------------------------------------------------
terminal = 'terminal'
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
mod = "Mod1"

awful.layout.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.floating,
} -- list of layouts

menu_awesome = {
   { "Hotkeys", function() popup_hotkeys.show_help(nil, awful.screen.focused()) end },
   { "Restart", awesome.restart },
   { "Quit", function() awesome.quit() end },
} -- context menu, awesome sub menu

menu = awful.menu({
   { "Awesome", menu_awesome, beautiful.awesome_icon },
   { "Set config", configsets },
   { "Session", powermenu },
   { "Terminal", terminal },
   { "Cancel", 'echo &' }
}) -- context menu, the main one

-- textclock widget
widget_textclock = wibox.widget.textclock()

widget_launcher = awful.widget.launcher({
   image = beautiful.awesome_icon,
   menu = menu
}) -- launcher ???

-- config menubar
menubar.utils.terminal = terminal

------------------------------------------------------------------------
--                           mouse bindding                           --
------------------------------------------------------------------------
local button_client = gears.table.join(
   awful.button({}, 1, function (c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
   end),
   awful.button({ mod }, 1, function (c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
      awful.mouse.client.move(c)
   end),
   awful.button({ mod }, 3, function (c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
      awful.mouse.client.resize(c)
   end)
) -- button_client

local button_root = gears.table.join(
   awful.button({}, 3, function () menu:toggle() end),
   awful.button({}, 4, awful.tag.viewnext),
   awful.button({}, 5, awful.tag.viewprev)
)

root.buttons(button_root)

------------------------------------------------------------------------
--                         binding: keyboard                          --
------------------------------------------------------------------------
key_root = gears.table.join(
   api.audio.key,
   api.brightness.key,
   awful.key({mod}, '/', function() popup_hotkeys.show_help(nil, awful.screen.focused()) end, {
      description = 'Show/hide help',
      group = 'Awesome'
   }),
   awful.key({mod}, 'd', function() awful.spawn("rofi -show run") end, {
      description = 'Show/hide help',
      group = 'Awesome'
   }),
   awful.key({mod}, 'w', function() menu:show() end, {
      description = 'Open context menu',
      group = 'Awesome'
   }),
   awful.key({mod}, 's', function() awful.screen.focus_relative(1) end, {
      description = 'Focus next screen',
      group = 'Awesome'
   }),
   awful.key({mod}, 'j', function() awful.client.focus.byidx(1) end, {
      description = 'Focus next client',
      group = 'Client'
   }),
   awful.key({mod}, 'k', function() awful.client.focus.byidx(-1) end, {
      description = 'Focus previous client',
      group = 'Client'
   }),
   awful.key({mod}, "l", function() awful.tag.incmwfact( 0.05) end, {
      description = "Increase master width factor",
      group = "Layout"
   }),
   awful.key({mod}, "h", function() awful.tag.incmwfact(-0.05) end, {
      description = "Decrease master width factor",
      group = "Layout"
   }),
   awful.key({mod}, 'Return', function() awful.spawn(terminal) end, {
      description = 'Spawn terminal',
      group = 'Awesome'
   }),
   awful.key({mod}, 'space', function() awful.layout.inc(1) end, {
      description = 'Next layout',
      group = 'Awesome'
   }),
   awful.key({mod, 'Shift'}, 'space', function() awful.layout.inc(-1) end, {
      description = 'Previous layout',
      group = 'Awesome'
   }),
   awful.key({mod, 'Shift'}, 'r', awesome.restart, {
      description = 'Restart awesome',
      group = 'Awesome',
   }),
   awful.key({mod, 'Shift'}, 'e', awesome.quit, {
      description = 'Quit awesome',
      group = 'Awesome',
   }),
   awful.key({mod, 'Shift'}, 'n', function()
      local c = awful.client.restore()
      if c then
         c:emit_signal("request::active", "key.unminimize", {
            raise = true
         })
      end
   end, {
      description = "Restore minimized client",
      group = "Client"
   })
) -- key_root

for i = 1,9 do
   key_root = gears.table.join(
      ---------------------
      --  view tag only  --
      ---------------------
      awful.key({mod}, "#" .. i + 9, function ()
         local screen = awful.screen.focused()
         local tag = screen.tags[i]
         if tag then
            tag:view_only()
         end
      end, {
         description = "view tag #"..i,
         group = "tag"
      }),
      --------------------------
      --  toggle tag display  --
      --------------------------
      awful.key({mod, "Control"}, "#" .. i + 9, function ()
         local screen = awful.screen.focused()
         local tag = screen.tags[i]
         if tag then
            awful.tag.viewtoggle(tag)
         end
      end, {
         description = "toggle tag #" .. i,
         group = "tag"
      }),
      --------------------------
      --  move client to tag  --
      --------------------------
      awful.key({mod, "Shift"}, "#" .. i + 9, function ()
         if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
               client.focus:move_to_tag(tag)
            end
         end
      end, {
         description = "move focused client to tag #"..i,
         group = "tag"
      })
   , key_root) -- key_root
end

local key_client = gears.table.join(
   awful.key({mod}, 'f', function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
   end, {
      description = "Toggle fullscreen",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "q", function(c) c:kill() end, {
      description = "Close",
      group = "Client"
   }),
   awful.key({mod, "Control"}, "space", awful.client.floating.toggle, {
      description = "Toggle floating",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "s", function(c) c:move_to_screen() end, {
      description = "Move to screen",
      group = "Client"
   }),
   awful.key({mod,},"t",function(c) c.ontop = not c.ontop end,  {
      description = "Toggle keep on top",
      group = "Client"
   }), 
   awful.key({mod, }, "n", function(c) c.minimized = true end, {
      description = "Minimize client",
      group = "Client"
   }),
   awful.key({mod}, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
   end, {
      description = "Toggle maximize",
      group = "Client"
   }),
   awful.key({mod, "Control"}, "m", function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
   end, {
      description = "Toggle maximize vertically",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "m", function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
   end, {
      description = "Toggle maximize horizontally",
      group = "Client"
   })
) --key_client
root.keys(key_root)

------------------------------------------------------------------------
--                               rules                                --
------------------------------------------------------------------------
awful.rules.rules = {
   -- All clients will match this rule.
   {
      rule = {},
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = key_client,
         buttons = button_client,
         screen = awful.screen.preferred,
         placement = awful.placement.no_overlap+awful.placement.no_offscreen
      }
   },

   -- Floating clients.
   {
      rule_any = {
         instance = {
            "DTA",  -- Firefox addon DownThemAll.
            "copyq",  -- Includes session name in class.
            "pinentry",
         },
         class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin",  -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer"
         },

         -- Note that the name property shown in xprop might be set slightly after creation of the client
         -- and the name shown there might not match defined rules here.
         name = {
            "Event Tester",  -- xev.
         },
         role = {
            "AlarmWindow",  -- Thunderbird's calendar.
            "ConfigManager",  -- Thunderbird's about:config.
            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
         }
      },
      properties = { floating = true }
   },

   -- Add titlebars to normal clients and dialogs
   {
      rule_any = {
         type = { "normal", "dialog" }
      },
      properties = { titlebars_enabled = true }
   },
}

------------------------------------------------------------------------
--                           handle signals                           --
------------------------------------------------------------------------
local clientshape = beautiful.common_shape(dpi(16))
client.connect_signal("tagged", function(c)
   c.shape                 = clientshape
   c.shape_bounding        = clientshape
   c.shape_clip            = clientshape
   c.shape_input           = clientshape
   c.client_shape_bounding = clientshape
   c.client_shape_clip     = clientshape
end)
-- when a new client appears
client.connect_signal("manage", function (c)
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end
   c.icon = gears.surface(beautiful.icon_dir.."homu.png")._native

   if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
end) -- manage signal

-- when client request titlbar(s)
client.connect_signal("request::titlebars", function(c)
   -- buttons for the titlebar
   local buttons = gears.table.join(
      awful.button({}, 1, function()
         c:emit_signal("request::activate", "titlebar", {raise = true})
         awful.mouse.client.move(c)
      end),
      awful.button({}, 3, function()
         c:emit_signal("request::activate", "titlebar", {raise = true})
         awful.mouse.client.resize(c)
      end)
   ) -- title bar buttons

   local ttb = awful.titlebar(c, {
      height = dpi(16),
      font = beautiful.boldfont
   })

   c.titlebar_icon = wibox.widget({ -- Left
      {
         {
            awful.titlebar.widget.iconwidget(c),
            wibox.widget.textbox(''),
            spacing = dpi(16),
            layout = wibox.layout.fixed.horizontal,
         },
         margins = dpi(4),
         widget = wibox.container.margin,
      },
      widget = wibox.container.background,
      buttons = buttons,
      shape = function(cr, w, h)
         cr:new_path()
         cr:move_to(0,0)
         cr:line_to(w - h/2, 0)
         cr:line_to(w, h/2)
         cr:line_to(w - h/2, h)
         cr:line_to(0, h)
         cr:line_to(0,0)
         cr:close_path()
      end,
      bg = beautiful.blue,
   })

   c.titlebar_buttons = wibox.widget({
      {
         -- awful.titlebar.widget.floatingbutton(c),
         -- awful.titlebar.widget.maximizedbutton(c),
         -- awful.titlebar.widget.stickybutton(c),
         -- awful.titlebar.widget.ontopbutton(c),
         awful.titlebar.widget.closebutton(c),
         layout = wibox.layout.fixed.horizontal()
      },
      margins = dpi(4),
      widget = wibox.container.margin
   })

   ttb:setup({
      c.titlebar_icon,
      { -- Middle
         { -- Title
            align  = "center",
            widget = awful.titlebar.widget.titlewidget(c)
         },
         buttons = buttons,
         layout  = wibox.layout.flex.horizontal
      },
      c.titlebar_buttons,
      layout = wibox.layout.align.horizontal
   })
end) -- handle title bar

-- enable sloppy focus
client.connect_signal("mouse::enter", function(c)
   c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- border when focus and unfocus
client.connect_signal("focus", function(c)
   c.border_color = beautiful.border_focus
   if c.titlebar_icon then
      c.titlebar_icon.bg = beautiful.blue
   end
   c.titlebar_buttons.visible = true
end)

client.connect_signal("unfocus", function(c)
   c.border_color = beautiful.border_normal
   c.titlebar_icon.bg = gears.color.transparent
   c.titlebar_buttons.visible = false
end)

-- wallpaper request
screen.connect_signal("request::wallpaper", function(s)
   -- Wallpaper
   if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper
      -- If wallpaper is a function, call it with the screen
      if type(wallpaper) == "function" then
         wallpaper = wallpaper(s)
      end
      gears.wallpaper.maximized(wallpaper, s, true)
   end
end)


screen.connect_signal("request::desktop_decoration", function(s)
   -- Each screen has its own tag table.
   for _,tag in pairs(beautiful.tags) do
      awful.tag.add(tag, {
         screen = s,
         layout = awful.layout.suit.tile,
         icon = gears.color.recolor_image(beautiful.taglist_icon[tag], beautiful.white)
      })
   end
   s:connect_signal("tag::history::update", function()
      for _, tag in ipairs(s.tags) do
         if tag.selected then
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
         else
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
         end
      end
   end)
   s.tags[1]:view_only()


   s.mypromptbox = awful.widget.prompt()

   s.layoutbox = ggz_layoutbox(s)

   -- Create the wiboxes
   s.wibox_top_left = awful.popup({
      type = 'dock', -- no shadow
      screen = s,
      height = beautiful.wibar_height,
      visible = true,
      bg = gears.color.transparent,
      widget = wibox.widget({
         margins = {
            top = beautiful.wibar_border_width,
            left = beautiful.wibar_border_width
         },
         s.info,
         widget = wibox.container.margin
      })
   })

   s.wibox_top_right = awful.popup({
      screen = s,
      placement = awful.placement.top_right,
      type = 'dock',
      bg = gears.color.transparent,
      widget = wibox.widget({
         widget = wibox.container.margin,
         margins = {
            top = beautiful.wibar_border_width,
            right = beautiful.wibar_border_width,
         },
         {
            spacing = beautiful.taglist_spacing,
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.layoutbox
         }
      }),
      visible = true,
   })

   -- set padding screen
   s.padding = {
      top = beautiful.wibar_height + beautiful.wibar_border_width * 2
   }
end) -- connect for each screen?
