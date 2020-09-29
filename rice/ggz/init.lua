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

-- @TODO:
-- remove this, this is global dpi function to keep
-- compability with the old code
dpi = beautiful.xresources.apply_dpi

-------------------
--  some config  --
-------------------
ign = os.getenv("USER") .. "@" .. io.popen("hostname"):read():match(".+") -- this will be displayed on the info panel
iglevel = 374 -- this will be displayed on the info panel

------------------------------------------------------------------------
--                           theming stuffs                           --
------------------------------------------------------------------------
-- beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
require("ggz.theme")
beautiful.wallpaper = "/home/hung/Pictures/wallpaper/index"
-- beautiful.wallpaper = beautiful.icon_dir .. "wallpaper.png"

------------------------------------------------------------------------
--                           custom widgets                           --
------------------------------------------------------------------------
local ggz_layoutbox = require("ggz.widgets.layoutbox")
-- require("ggz.mediapopup")
require("ggz.widgets.tasklist")
require("ggz.widgets.taglist")
require("ggz.widgets.promptbox")
require("ggz.widgets.info")
local Testprompt = require("awesome-prompt")
local prompt = Testprompt({
   placement = 'top',
   forced_width = awful.screen.focused().geometry.width / 3,
   -- forced_height = awful.screen.focused().geometry.height,
   style = {
      prompt_item_bg = {beautiful.shade},
      prompt_item_fg = {"#f2f3f4"},
      prompt_item_bg_selected = beautiful.blue,
      prompt_item_fg_selected = beautiful.shade,
   }
})
local powermenu = Testprompt({})
powermenu = Testprompt({
   -- no_prompt = true,
   prompt = "What to do? ",
   style = {
      prompt_item_bg = {
         "#323238",
         "#1d1f21",
         "#232425"
      }
   },
   buttons = gears.table.join(awful.button({}, 1, function(t, _)
	if type(t) == "table" then
		if type(t.exec) == "function" then t.exec()
		elseif type(t.exec) == "string" then awful.spawn(t.exec)
		end
	elseif type(t) == "string" then
		awful.spawn(t)
	end
        powermenu:dismiss()
   end)),
   layout = wibox.layout.fixed.vertical,
   completion_layout = wibox.layout.fixed.horizontal,
   placement = "top",
   -- shape = beautiful.common_shape(dpi(16)),
   execs = {
      {
         label = "Say hi",
         exec = function() notify({ text = "hi" }) end,
      },
      {
         label = "Logout",
         exec = awesome.quit,
      },
      {
         label = "Reboot",
         exec = "systemctl reboot"
      },
      {
         label = "Shutdown",
         exec = "systemctl poweroff"
      },
      {
         label = "Hibernate",
         exec = "systemctl hibernate"
      },
      {
         label = "Suspend",
         exec = "systemctl suspend"
      },
      {
         label = "Restart Awesome",
         exec = awesome.restart,
      },
   }
})
-- testprompt:run()

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
terminal = 'x-terminal-emulator'
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
-- notify({ text= tostring(key_client) })
key_root = gears.table.join(
   key_root,
   api.audio.key,
   api.brightness.key,
   awful.key({mod, "Shift"}, "d", function()
      awful.spawn("rofi -show run")
   end),
   awful.key({mod}, "d", function()
      prompt:run()
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


awful.screen.connect_for_each_screen(function(s)
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



   s.layoutbox = ggz_layoutbox(s)

   s.bar = wibox({
      type = 'dock',
      x = 2*beautiful.useless_gap + s.geometry.x,
      y = beautiful.useless_gap + s.geometry.y,
      width = s.geometry.width - 4 * beautiful.useless_gap,
      height = beautiful.wibar_height,
      visible = true,
      bg = gears.color.transparent,
      widget = wibox.widget({
         layout = wibox.layout.align.horizontal,
         {
            s.info,
            layout = wibox.layout.fixed.horizontal,
         },
         nil,
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = beautiful.taglist_spacing,
            s.mytaglist,
            s.layoutbox
         }
      })
   })

   -- set padding screen
   s.padding = {
      top = beautiful.wibar_height + beautiful.wibar_border_width * 2
   }
end) -- connect for each screen?

local common = require"common"
common:setup(common.Default)
