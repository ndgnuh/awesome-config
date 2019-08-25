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
local dpi = dpi
local screen = screen
local awesome = awesome
api.audio.set_step(5)

------------------------------------------------------------------------
--                           theming stuffs                           --
------------------------------------------------------------------------
local themefile = "/home/hung/.config/awesome/fancy/theme2.lua"
beautiful.init(themefile)
-- beautiful.wallpaper = "~/hexa2.png"
-- notify{ text = gears.debug.dump(beautiful.get()) }

------------------------------------------------------------------------
--                              widgets                               --
------------------------------------------------------------------------
require("fancy.widgets.tasklist")
require("fancy.widgets.taglist")
require("fancy.widgets.popup")
local battery = require("fancy.widgets.battery")
local Prompt = require("awesome-prompt")
local promptarg = {
   forced_width = 512,
   placement = function(s)
      return awful.placement.top(s, {offset = {y = beautiful.wibar_height * 2}})
   end,
   border_width = dpi(2),
   border_color = beautiful.blue,
   prompt = "Run: ",
   prompt_style = {
      fg_cursor = "#FFFFFF",
      bg_cursor = "#FF0000",
   },
   widget = wibox.widget{
      layout = wibox.layout.fixed.vertical,
      {
         widget = wibox.container.background,
         {
            widget = wibox.container.margin,
            margins = dpi(16),
            {
               widget = wibox.widget.textbox,
               id = "prompt_role",
            },
         }
      },
      {
         widget = wibox.layout.fixed.vertical,
         forced_width = 512,
         id = "completion_role"
      }
   }
}
local powermenu = Prompt(gears.table.join(
      promptarg,
      {
         execs = {
            { label = "Shutdown", exec = "systemctl poweroff" },
            { label = "Reboot", exec = "systemctl reboot" },
            { label = "Hibernate", exec = "systemctl hibernate" },
            { label = "Suspend", exec = "systemctl suspend" },
            { label = "Logout", exec = function() awesome.quit() end},
         }
      }
   ))

------------------------------------------------------------------------
--                          auto start stuff                          --
------------------------------------------------------------------------
awful.spawn.once("xrandr --output HDMI1 --left-of eDP1")
awful.spawn.once("compton")
awful.spawn.once("nm-applet")
awful.spawn.once("ibus-daemon -rdx")


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

local powermenu = {
   {
      "Lock screen", function() notify{ text = "Not available yet" } end
   },
   {
      "Logout", function() awesome.quit() end
   },
   {
      "Reboot", "systemctl reboot"
   },
   {
      "Shutdown", "systemctl poweroff"
   },
}
menu_awesome = {
   { "hotkeys", function() popup_hotkeys.show_help(nil, awful.screen.focused()) end },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
} -- context menu, awesome sub menu

menu = awful.menu({
   { "Awesome", menu_awesome, beautiful.awesome_icon },
   { "Set config", configsets },
   { "Session", powermenu },
   { "Terminal", terminal },
   { "Cancel", 'echo &' },
   { "Test", test }
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
key_root,key_client = table.unpack(require("basic.keys"))
key_root = gears.table.join(
   key_root,
   api.audio.key,
   api.brightness.key,
   awful.key({mod, "Shift"}, "d", function()
      awful.spawn("rofi -show run")
   end),
   awful.key({mod}, "d", function()
      require("rofi").run()
   end),
   awful.key({mod, "Shift"}, "e", function()
      powermenu:run()
   end)
)
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
-- local clientshape = gears.shape.rounded_rect
client.connect_signal("property::name", function(c)
   if c.name and #c.name > 30 then
      c.name =  c.name:sub(1,27) .. "..."
   end
end)
-- when a new client appears
client.connect_signal("manage", function (c)
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end
   -- c.icon = gears.surface(beautiful.icon_dir.."homu.png")._native

   if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
end) -- manage signal

-- when client request titlbar(s)
client.connect_signal("request::titlebars", function(c)
   -- set default icon
   if not c.icon then
      c.icon = gears.surface(beautiful.icondir .. "default.svg")._native
   end
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
   local titlebar_height = dpi(42)
   local titlebar = awful.titlebar(c, {
      size = beautiful.wibar_height,
      font = beautiful.boldfont,
      position = "top"
   })

   -- c.titlebar_buttons = wibox.widget({
   --    {
   --       -- awful.titlebar.widget.stickybutton(c),
   --       awful.titlebar.widget.closebutton(c),
   --       spacing = dpi(8),
   --       layout = wibox.layout.fixed.horizontal()
   --    },
   --    margins = dpi(4),
   --    widget = wibox.container.margin
   -- })


   titlebar:setup({
      {
         {
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.ontopbutton(c),
         },
         widget = wibox.container.margin,
         margins = dpi(4)
      },
      { -- Middle
         awful.titlebar.widget.titlewidget(c),
         widget = wibox.container.place
      },
      {
         {
            spacing = dpi(8),
            layout = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.closebutton(c),
         },
         widget = wibox.container.margin,
         margins = dpi(4)
      },
      -- c.titlebar_buttons,
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
   -- c.titlebar_buttons.visible = true
end)

client.connect_signal("unfocus", function(c)
   c.border_color = beautiful.border_normal
   -- c.titlebar_buttons.visible = false
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
   awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])

   s.bar2 = awful.wibar {
      position = "top",
      -- bgimage = "/home/hung/hexa2.png",
      stretch = true,
      screen = s,
   }

   s.bar = awful.wibar {
      screen = s,
      position = "left",
      -- bgimage = "/home/hung/hexa2.png",
      stretch = true,
   }

   s.tray = wibox.widget.systray()
   s.tray:set_horizontal(false)

   s.bar2:setup {
      {
         awful.widget.layoutbox,
         layout = wibox.layout.fixed.horizontal,
         forced_width = beautiful.wibar_height,
      },
      {
         widget = s.tasklist,
      },
      -- wibox.widget.textclock("%A, %d/%m/%Y"),
      layout = wibox.layout.align.horizontal,
   }

   s.textclock = wibox.widget.textclock("%H\n%M")
   s.month_calendar = awful.widget.calendar_popup.month()
   s.month_calendar:attach( s.textclock, "c" )

   s.bar:setup {
      s.taglist,
      nil,
      {
         widget = wibox.container.margin,
         margins = dpi(8),
         { -- bottom
            {
               s.tray,
               battery,
               wibox.container.place(s.textclock),
               -- wibox.layout.fixed.vertical(
               --    wibox.widget.textclock("%M")
               -- ),
               spacing = dpi(4),
               layout = wibox.layout.fixed.vertical,
            },
            halign = "center",
            widget = wibox.container.place,
         },
      },
      layout = wibox.layout.align.vertical,
   }
   -- set padding screen
   -- s.padding = {
   --    top = beautiful.wibar_height + beautiful.wibar_border_width * 2
   -- }
end) -- connect for each screen?
