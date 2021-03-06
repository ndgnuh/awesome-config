-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local common = require"common"
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local partial = require("Partial")

-- do -- @use_all_the_functions_from_c_utils
--   local c_utils = require("c_utils")
--   for k, f in pairs(c_utils) do
--     _G[k] = f
--   end
-- end
-- require("configuration")
-- require("util")
-- require("util.math")
-- require("util.color")
-- require("Extend")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify
      {
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
      }
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal (
      "debug::error",
      function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify
          {
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
          }
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
do
  local cdir = require("Dir")()
  local themefile = cdir .. "theme/tempus-night.lua"
  beautiful.init(themefile)
end

-- {{{ @libs
-- custom library and module goes here
local sh = require("sh")
local ic = require("icon")
-- }}}

-- This is used later as the default terminal and editor to run.

-- editor = os.getenv("EDITOR") or "nano"
-- editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.

-- Table of layouts to cover with awful.layout.inc, order matters.
-- awful.layout.layouts = {
--   awful.layout.suit.floating,
--   awful.layout.suit.max,
--   awful.layout.suit.tile,
--   -- awful.layout.suit.tile.left,
--   -- awful.layout.suit.tile.bottom,
--   -- awful.layout.suit.tile.top,
--   -- awful.layout.suit.fair,
--   -- awful.layout.suit.fair.horizontal,
--   -- awful.layout.suit.spiral,
--   -- awful.layout.suit.spiral.dwindle,
--   -- awful.layout.suit.max.fullscreen,
--   -- awful.layout.suit.magnifier,
--   -- awful.layout.suit.corner.nw,
--   -- awful.layout.suit.corner.ne,
--   -- awful.layout.suit.corner.sw,
--   -- awful.layout.suit.corner.se,
-- }
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   --{ "manual", terminal .. " -e man awesome" },
   -- { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu{
  items = {
    { "awesome", myawesomemenu },
    require("Rice").menu,
    -- { "open terminal", terminal }
  }
}

mylauncher = awful.widget.launcher{
  image = beautiful.awesome_icon,
  menu = mymainmenu
}
mylauncher:buttons(gears.table.join(
    awful.button({}, 1, function()
      mymainmenu:show()
    end),
    awful.button({}, 3, function()
      awful.spawn.easy_async_with_shell("$HOME/.config/rofi/scripts/appsmenu.sh", pass)
    end)
  ))

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local ibus_widget = require"ibus-widget"

mytextclock = wibox.widget{
  widget = wibox.container.place,
  {
    widget = wibox.widget.textclock,
    format = "<b>%I\n%M</b>\n<u><i>%p</i></u>",
    forced_width = beautiful.wibar_width,
    align = 'center',
    valign = 'center',
    font = 'monospace',
  },
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
  )


local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local tasklist = require"TaskList"

local w_battery = require"battery"
awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({1}, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
      screen  = s,
      filter  = function() return false end, --awful.widget.taglist.filter.all,
      buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = tasklist(s)

    -- Create the wibox
    s.mywibox =
      awful.wibar{
        position = "left",
        screen   = s
      }

    -- Add widgets to the wibox
    local left_layout =
      wibox.layout.fixed.vertical()
    left_layout:add(mylauncher)
    left_layout:add(s.mypromptbox)

    local right_layout = wibox.layout.fixed.vertical()
    right_layout:add(s.mytasklist)
    right_layout:add(ibus_widget)
    right_layout:add(w_battery)
    if s == screen.primary then
      right_layout:add(wibox.widget{
        widget = wibox.container.rotate,
        wibox.widget.systray(),
        direction = "west",
      })
    end
    right_layout:add(mytextclock)
    right_layout:add(s.mylayoutbox)

    local bar_layout = wibox.layout.align.vertical()
    bar_layout:set_first(left_layout)
    bar_layout:set_second(middle_layout)
    bar_layout:set_third(right_layout)

    s.mywibox:set_widget(bar_layout)

    -- dump({s.mywibox:get_children_by_id('ibus-engine')})--:get_children_by_id('ibus-engine'))
    
    -- setup bounding corners
    -- must run after setting up wibar
    require"rounded_corner_padding"(s)
  end)
  -- @end_each_screen_callback
  -- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- root.keys({})
-- 
-- local TaskSwitcher = require("TaskSwitcher")
-- local ts = TaskSwitcher()
-- 
-- 
-- --[[
-- globalkeys = gears.table.join(
--   awful.key({modkey}, "j", function() ts:trigger() ts:emit_signal("forward") end),
--   awful.key({modkey}, "k", function() ts:trigger() ts:emit_signal("backward") end),
--     awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
--               {description="show help", group="awesome"}),
--     awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
--               {description = "view previous", group = "tag"}),
--     awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
--               {description = "view next", group = "tag"}),
--     awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
--               {description = "go back", group = "tag"}),
-- 
--     -- awful.key({ modkey,           }, "j",
--     --     function ()
--     --         awful.client.focus.byidx( 1)
--     --     end,
--     --     {description = "focus next by index", group = "client"}
--     -- ),
--     -- awful.key({ modkey,           }, "k",
--     --     function ()
--     --         awful.client.focus.byidx(-1)
--     --     end,
--     --     {description = "focus previous by index", group = "client"}
--     -- ),
--     awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
--               {description = "show main menu", group = "awesome"}),
-- 
--     -- Layout manipulation
--     awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
--               {description = "swap with next client by index", group = "client"}),
--     awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
--               {description = "swap with previous client by index", group = "client"}),
--     awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
--               {description = "focus the next screen", group = "screen"}),
--     awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
--               {description = "focus the previous screen", group = "screen"}),
--     awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
--               {description = "jump to urgent client", group = "client"}),
-- --    awful.key({ modkey,           }, "Tab",
-- --        function ()
-- --            awful.client.focus.history.previous()
-- --            if client.focus then
-- --                client.focus:raise()
-- --            end
-- --        end,
-- --        {description = "go back", group = "client"}),
-- 
--     -- Standard program
--     awful.key({ modkey, "Control" }, "r", awesome.restart,
--               {description = "reload awesome", group = "awesome"}),
--     awful.key({ modkey, "Shift"   }, "e", awesome.quit,
--               {description = "quit awesome", group = "awesome"}),
-- 
--     awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
--               {description = "increase master width factor", group = "layout"}),
--     awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
--               {description = "decrease master width factor", group = "layout"}),
--     awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
--               {description = "increase the number of master clients", group = "layout"}),
--     awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
--               {description = "decrease the number of master clients", group = "layout"}),
--     awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
--               {description = "increase the number of columns", group = "layout"}),
--     awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
--               {description = "decrease the number of columns", group = "layout"}),
-- --    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
-- --              {description = "select next", group = "layout"}),
--     awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
--               {description = "select previous", group = "layout"}),
-- 
--     awful.key({ modkey, "Shift" }, "n",
--               function ()
--                   local c = awful.client.restore()
--                   -- Focus restored client
--                   if c then
--                     c:emit_signal(
--                         "request::activate", "key.unminimize", {raise = true}
--                     )
--                   end
--               end,
--               {description = "restore minimized", group = "client"}),
-- 
--     -- Prompt
--     awful.key({ modkey }, "r", function()
--      -- awful.screen.focused().mypromptbox:run() end,
--      awful.spawn(string.format('rofi -show run', os.getenv("HOME")))
--    end,
--    {description = "run prompt", group = "launcher"}),
-- 
--     awful.key({ modkey }, "x",
--               function ()
--                   awful.prompt.run {
--                     prompt       = "Run Lua code: ",
--                     textbox      = awful.screen.focused().mypromptbox.widget,
--                     exe_callback = awful.util.eval,
--                     history_path = awful.util.get_cache_dir() .. "/history_eval"
--                   }
--               end,
--               {description = "lua execute prompt", group = "awesome"}),
--     -- Menubar
--     awful.key({ modkey }, "p", function() menubar.show() end,
--               {description = "show the menubar", group = "launcher"})
-- )
-- --]]
-- 
-- 
-- clientkeys = gears.table.join(
--     awful.key({ modkey,           }, "f",
--         function (c)
--             c.fullscreen = not c.fullscreen
--             c:raise()
--         end,
--         {description = "toggle fullscreen", group = "client"}),
--     awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
--               {description = "toggle floating", group = "client"}),
--     awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
--               {description = "move to master", group = "client"}),
--     awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
--               {description = "move to screen", group = "client"})
-- --    awful.key({ modkey,           }, "n",
-- --        function (c)
-- --            -- The client currently has the input focus, so it cannot be
-- --            -- minimized, since minimized clients can't have the focus.
-- --            c:emit_signal("before::minimize")
-- --            c.minimized = true
-- --        end ,
-- --  {description = "minimize", group = "client"}),
-- --    awful.key({ modkey,           }, "m",
-- --        function (c)
-- --            c.maximized = not c.maximized
-- --            c:raise()
-- --        end ,
-- --        {description = "(un)maximize", group = "client"}),
-- --    awful.key({ modkey, "Control" }, "m",
-- --        function (c)
-- --            c.maximized_vertical = not c.maximized_vertical
-- --            c:raise()
-- --        end ,
-- --        {description = "(un)maximize vertically", group = "client"}),
-- --    awful.key({ modkey, "Shift"   }, "m",
-- --        function (c)
-- --            c.maximized_horizontal = not c.maximized_horizontal
-- --            c:raise()
-- --        end ,
-- --        {description = "(un)maximize horizontally", group = "client"})
-- )
-- 
-- clientbuttons = gears.table.join(
--     awful.button({ }, 1, function (c)
--         c:emit_signal("request::activate", "mouse", {raise = true})
--     end),
--     awful.button({ modkey }, 1, function (c)
--         c:emit_signal("request::activate", "mouse", {raise = true})
--         awful.mouse.client.move(c)
--     end),
--     awful.button({ modkey }, 3, function (c)
--         c:emit_signal("request::activate", "mouse", {raise = true})
--         awful.mouse.client.resize(c)
--     end)
-- )
-- 
-- -- Set keys
-- -- root.keys(globalkeys)
-- awful.add_key_binding(
--   awful.key({"Mod4", "Shift"}, "r", awesome.restart),
--   awful.key({modkey}, "Return", partial(awful.spawn, terminal)),
--   awful.key({}, "Print", partial(awful.spawn.raise_or_spawn, "gscreenshot"))
--   )
-- 
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
-- awful.rules.rules = {
--   {
--     rule_any = {
--       class = {
--         "URxvt",
--         "x-terminal-emulator",
--       }
--     },
--     properties = {
--       size_hints_honor = false
--     }
--   },
--   -- All clients will match this rule.
--   { rule = { },
--     properties = { border_width = beautiful.border_width,
--       border_color = beautiful.border_normal,
--       focus = awful.client.focus.filter,
--       raise = true,
--       keys = clientkeys,
--       buttons = clientbuttons,
--       screen = awful.screen.preferred,
--       placement = awful.placement.no_overlap+awful.placement.no_offscreen
--     }
--   },
-- 
--   -- Floating clients.
--   { rule_any = {
--       instance = {
--         "DTA",  -- Firefox addon DownThemAll.
--         "copyq",  -- Includes session name in class.
--         "pinentry",
--       },
--       class = {
--         "Arandr",
--         "Blueman-manager",
--         "Gpick",
--         "Kruler",
--         "MessageWin",  -- kalarm.
--         "Sxiv",
--         "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
--         "Wpa_gui",
--         "veromix",
--       "xtightvncviewer"},
-- 
--       -- Note that the name property shown in xprop might be set slightly after creation of the client
--       -- and the name shown there might not match defined rules here.
--       name = {
--         "Event Tester",  -- xev.
--         "Picture-in-Picture", -- firefox picture in picture
--       },
--       role = {
--         "AlarmWindow",  -- Thunderbird's calendar.
--         "ConfigManager",  -- Thunderbird's about:config.
--         "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
--       }
--   }, properties = { floating = true }},
-- 
--   -- Add titlebars to normal clients and dialogs
--   { rule_any = {type = { "normal", "dialog" }
--     }, properties = { titlebars_enabled = true }
--   },
-- 
--   -- Set Firefox to always map on the tag named "2" on screen 1.
--   -- { rule = { class = "Firefox" },
--   --   properties = { screen = 1, tag = "2" } },
-- }
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({ }, 1, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.resize(c)
    end)
    )


  awful.titlebar(c, {size = beautiful.wibar_width}) : setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.minimizebutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

local Mod = {modkey}
local onlytag

local IBus = require"IBus"

-- awful.add_key_binding(
--   IBus.key(Mod, "space", { "xkb:us::eng", "Bamboo" }),
--   awful.key(Mod, "Tab", require"focusPrevious", {description = "go back", group = "client"}),
--   awful.key(Mod, "0", function()
--     if awful.tag.selected() then
--       onlytag =
--         awful.tag.selected()
--       awful.tag.viewnone()
--     else
--       onlytag:view_only()
--     end
--   end),
--     {})

require"pulse-shortcut"

client.connect_signal("manage", function(c)
	local icon = require"icon"
	if not c.icon then
		c.icon = gears.color.recolor_image(icon"mdi/application.svg", "#FFFFFF")._native
	end
end)

common.dispatches["app/menu"] = function() mymainmenu:show() end
common:setup("w")

require"common"
