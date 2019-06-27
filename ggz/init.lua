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

------------------------------------------------------------------------
--                           theming stuffs                           --
------------------------------------------------------------------------
beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
require("ggz.theme")
beautiful.wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper"

------------------------------------------------------------------------
--                           custom widgets                           --
------------------------------------------------------------------------
local ggz_layoutbox = require("ggz.widget_layoutbox")
local widget_volume = require("ggz.widget_volume")

------------------------------------------------------------------------
--                          auto start stuff                          --
------------------------------------------------------------------------
awful.spawn.once("xrandr --output HDMI1 --left-of eDP1")
awful.spawn.once("compton")


------------------------------------------------------------------------
--                            handle error                            --
------------------------------------------------------------------------
if awesome.startup_errors then
   naughty.notification({
      preset = naughty.config.presets.critical,
      title = "Unknown error has occured",
      message = awesome.startup_errors
   })
   awful.spawn.with_shell("echo " .. awesome.startup_errors .. " | tee ~/awesome$(date).log")
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
         message = awesome.startup_errors
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

local button_taglist = gears.table.join(
   awful.button({}, 1, function(t)
      t:view_only()
      for _, tag in ipairs(awful.screen.focused().tags) do
         if tag.selected then
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
         else
            tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
         end
      end
   end),
   awful.button({}, 3, awful.tag.viewtoggle)
)

local button_tasklist = gears.table.join(
   awful.button({}, 1, function (c)
      if c == client.focus then
         c.minimized = true
      else
         c:emit_signal("request::activate", "tasklist", {raise = true})
      end
   end),
   awful.button({}, 3, function()
      awful.menu.client_list({ theme = { width = 250 } })
   end),
   awful.button({}, 4, function ()
      awful.client.focus.byidx(1)
   end),
   awful.button({}, 5, function ()
      awful.client.focus.byidx(-1)
   end)
)

root.buttons(button_root)

------------------------------------------------------------------------
--                         binding: keyboard                          --
------------------------------------------------------------------------
key_root = gears.table.join(
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
         for _, tag in ipairs(screen.tags) do
            if tag.selected then
               tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
            else
               tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
            end
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
         for _, tag in ipairs(screen.tags) do
            if tag.selected then
               tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
            else
               tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
            end
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
-- when a new client appears
client.connect_signal("manage", function (c)
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end
   if not c.icon then
      c.icon = gears.surface(os.getenv("HOME") .. "/.config/awesome/defaulticon.svg")._native
   end

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

   awful.titlebar(c):setup({
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
         awful.titlebar.widget.maximizedbutton(c),
         awful.titlebar.widget.stickybutton(c),
         awful.titlebar.widget.ontopbutton(c),
         awful.titlebar.widget.closebutton(c),
         layout = wibox.layout.fixed.horizontal()
      },
      layout = wibox.layout.align.horizontal
   })
end) -- handle title bar

-- enable sloppy focus
client.connect_signal("mouse::enter", function(c)
   c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- border when focus and unfocus
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

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

-- require("ggz.ggz_layoutbox")
-- connect_for_each_screen


screen.connect_signal("request::desktop_decoration", function(s)

   -- Each screen has its own tag table.
   awful.tag.add("Web", {
      screen = s,
      layout = awful.layout.suit.tile,
      icon = gears.color.recolor_image(beautiful.taglist_icon.web, beautiful.white)
   })
   awful.tag.add("Term", {
      screen = s,
      layout = awful.layout.suit.tile,
      icon = gears.color.recolor_image(beautiful.taglist_icon.term, beautiful.white)
   })
   awful.tag.add("Docs", {
      screen = s,
      layout = awful.layout.suit.tile,
      icon = gears.color.recolor_image(beautiful.taglist_icon.doc, beautiful.white)
   })
   awful.tag.add("Media", {
      screen = s,
      layout = awful.layout.suit.float,
      icon = gears.color.recolor_image(beautiful.taglist_icon.media, beautiful.white)
   })
   awful.tag.add("Extra", {
      screen = s,
      layout = awful.layout.suit.tile,
      icon = gears.color.recolor_image(beautiful.taglist_icon["extra"], beautiful.white)
   })

   s.info = wibox.widget({
      {
         layout = wibox.layout.fixed.horizontal,
         {
            forced_width = beautiful.wibar_height,
            forced_height = beautiful.wibar_height,
            widget = wibox.container.radialprogressbar,
            color = beautiful.orange,
            border_color = beautiful.orange,
            border_width = dpi(4),
            padding = dpi(4),
            {
               widget = wibox.widget.imagebox,
               image = beautiful.icon_dir .. "hakase.png",
            },
         },
         {
            {
               {
                  markup = '<span color=\'' .. beautiful.white .. '\'>' .. os.getenv("USER")  .. '@arch</span>',
                  font = 'Segoe UI bold 11',
                  align = 'center',
                  widget = wibox.widget.textbox,
               },
               {
                  {
                     widget = wibox.widget.textbox,
                     markup = '<span color=\'' .. beautiful.white .. '\'>BAT</span>',
                     font = 'Segoe UI bold 11',
                  },
                  {
                     {
                        widget = wibox.widget.progressbar,
                        shape = gears.shape.rounded_bar,
                        forced_height = dpi(8),
                        max_value = 100,
                        value = 80,
                     },
                     {
                        markup = '<span color=\'' .. beautiful.white .. '\'>80/100</span>',
                        widget = wibox.widget.textbox,
                        align = 'center',
                        font = 'Segoe UI bold 8'
                     },
                     layout = wibox.layout.stack
                  },
                  layout = wibox.layout.fixed.horizontal
               },
               {
                  {
                     {
                        widget = wibox.widget.imagebox,
                        image = gears.color.recolor_image(beautiful.icon_dir .. "time.png", beautiful.yellow),
                     },
                     widget_textclock,
                     spacing = dpi(8),
                     layout = wibox.layout.fixed.horizontal,
                  },
                  {
                     {
                        widget = wibox.widget.imagebox,
                        image = gears.color.recolor_image(beautiful.taglist_icon.media, beautiful.blue),
                     },
                     widget_volume,
                     spacing = dpi(8),
                     layout = wibox.layout.fixed.horizontal,
                  },
                  layout = wibox.layout.flex.horizontal
               },
               layout = wibox.layout.ratio.vertical
            },
            margins = {
               left = dpi(16),
               right = dpi(16),
               top = dpi(4),
               bottom = dpi(4)
            },
            widget = wibox.container.margin
         },
      },
      bg = beautiful.shade,
      widget = wibox.container.background,
      border_width = beautiful.taglist_shape_border_width,
      border_color = beautiful.taglist_shape_border_color,
      shape = function(cr, w, h)
         local r = dpi(16)
         local mr = r/2.5
         local br = h/2
         cr:arc(br, br, br, math.pi, 3*math.pi/2)
         cr:arc(w-mr, mr, mr, 3*math.pi/2, 0)
         -- cr:line_to(w, 0)
         cr:arc(w-r, h-r, r, math.pi*2 , math.pi/2)
         cr:arc(br, h-br, br, math.pi/2, math.pi)
         -- cr:line_to(0, h)
         cr:line_to(0, br)
         cr:close_path()
      end,
      forced_width = dpi(256) * 1.5,
      forced_height = beautiful.wibar_height,
   })

   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt()

   s.layoutbox = ggz_layoutbox(s)
   -- require("ggz.widget_layoutbox")
   -- Create an imagebox widget which will contain an icon indicating which layout we're using.
   -- We need one layoutbox per screen.

   -- Create a taglist widget
   s.mytaglist = awful.widget.taglist({
      screen  = s,
      filter  = awful.widget.taglist.filter.all,
      buttons = button_taglist,
      widget_template = {
         {
            {
               {
                  widget = wibox.container.place,
                  {
                     widget = wibox.widget.imagebox,
                     resize = true,
                     id = 'icon_role',
                  },
               },
               {
                  widget = wibox.widget.textbox,
                  id = 'text_role',
                  align = 'center'
               },
            layout = wibox.layout.flex.vertical,
            },
            widget = wibox.container.margin,
            left = beautiful.taglist_shape_border_width,
            right = beautiful.taglist_shape_border_width,
            top = dpi(8),
            bottom = dpi(8),
         },
         forced_width = beautiful.wibar_height,
         forced_height = beautiful.wibar_height,
         id = 'background_role',
         widget = wibox.container.background,
         -- update_callback = function(self, c3, index, objects) --luacheck: no unused args
         --    self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
         -- end,
      }
   })

   -- Create a tasklist widget
   s.mytasklist = awful.widget.tasklist({
      screen  = s,
      filter  = awful.widget.tasklist.filter.focused,
      buttons = button_tasklist,
      widget_template = {
         {
            {
               widget = wibox.widget.imagebox,
               id = 'icon_role'
            },
            {
               align = 'center',
               widget = wibox.widget.textbox,
               id = 'text_role',
            },
            layout = wibox.layout.align.horizontal
         },
         widget = wibox.container.background,
         id = 'background_role'
      }
   })

   -- Create the wibox
   s.mywibox = awful.wibar({ position = "top", screen = s })

   -- Add widgets to the wibox
   s.mywibox:setup({
      layout = wibox.layout.align.horizontal,
      spacing = beautiful.taglist_spacing,
      { -- Left widgets
         wibox.widget.textbox(),
         s.info,
         layout = wibox.layout.fixed.horizontal,
         mylauncher,
         -- widget_textclock,
         s.mypromptbox,
         -- wibox.widget.systray(),
      },
      { -- center widget
         -- s.mytasklist,
         widget = wibox.container.margin,
         margins = {
            left = dpi(8),
            right = dpi(8),
            top = beautiful.wibar_height/2,
            bottom = beautiful.wibar_border_width,
         }
      },
      { -- Right widgets
         spacing = beautiful.taglist_spacing,
         layout = wibox.layout.fixed.horizontal,
         s.mytaglist,
         s.layoutbox
      },
   })
end) -- connect for each screen?

local function taglist_update()
   local screen = awful.screen.focused()
   for _, tag in ipairs(screen.tags) do
      if tag.selected then
         tag.icon = gears.color.recolor_image(tag.icon, beautiful.blue)
      else
         tag.icon = gears.color.recolor_image(tag.icon, beautiful.white)
      end
   end
end
