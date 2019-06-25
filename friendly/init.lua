-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local cairo = require("lgi").cairo
local freedesktop = require("freedesktop")

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
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notification {
        preset  = naughty.config.presets.critical,
        title   = "Oops, there were errors during startup!",
        message = awesome.startup_errors
    }
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notification {
            preset  = naughty.config.presets.critical,
            title   = "Oops, an error happened!",
            message = tostring(err)
        }

        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
beautiful.wallpaper = os.getenv("HOME") .. '/Pictures/wallpaper.jpg'
beautiful.systray_icon_spacing = dpi(2)
beautiful.icon_theme = "Papirus"
beautiful.useless_gaps = 0
-- require("friendly.theme")

-- This is used later as the default terminal and editor to run.
terminal = "terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = { 
    awful.layout.suit.floating,
    awful.layout.suit.fair,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
}


powermenu = {
    { "Poweroff", "systemctl poweroff" },
    { "Reboot", "systemctl reboot" },
    { "Logout", function() awesome.quit() end},
    { "Hibernate", "systemctl hibernate" },
    { "Suspend", "systemctl suspend" }
}

tiling = {
    { "Tile" , function() awful.layout.set(awful.layout.suit.fair) end },
    { "Float" , function() awful.layout.set(awful.layout.suit.floating) end },
}

-- configset 
mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
    },
    after = {
        { "Power", powermenu },
        { "Tiling", tiling },
        { "Config set", configsets },
        { "Terminal", terminal },
        { "Cancel", 'echo abc &' },
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = {
    awful.button({ }, 1, function(t) t:view_only() end), awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
}

local taglist_buttons = gears.table.join(table.unpack(taglist_buttons))

local tasklist_buttons = {
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(table.unpack({
                "request::activate",
                "tasklist",
                {raise = true}
            }))
        end
    end),
    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
}
local tasklist_buttons = gears.table.join(table.unpack(tasklist_buttons))

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
    awful.tag({ "only" }, s, awful.layout.layouts[1])
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- show desktop button
    s.show_desktop = wibox.widget.textbox("  ")
    s.show_desktop:connect_signal("mouse::enter", function() awful.tag.viewnone() end)
    s.show_desktop:connect_signal("mouse::leave", function ()
        awful.tag.find_by_name(awful.screen.focused(), "only"):view_only()
    end)

    -- Create a tasklist widget
    s.friendly_tasklist = awful.widget.tasklist {
        screen = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            spacing_widget = {
                {
                    forced_width  = 5,
                    forced_height = 24,
                    thickness     = 1,
                    color         = '#777777',
                    widget        = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            spacing = 1,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            id = 'background_role',
            forced_width = dpi(256),
            widget = wibox.container.background,
            {
                {
                    {
                        {
                            id = 'clienticon',
                            widget = awful.widget.clienticon,
                        },
                        {
                            id = 'text_role',
                            widget = wibox.widget.textbox,
                        },
                        layout = wibox.layout.fixed.horizontal
                    },
                    margins = dpi(5),
                    widget = wibox.container.margin
                },
                halign = "left",
                widget = wibox.container.place
            },
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })


    -- Add widgets to the wibox
    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.friendly_tasklist, -- Middle widget
            s.mypromptbox,
        },
        nil,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            {
                wibox.widget.systray(),
                margins = dpi(4),
                widget = wibox.container.margin
            },
            mytextclock,
            s.show_desktop
        }
    })

    -- freedesktop.desktop.add_icons({screen = s})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(table.unpack({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
})))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(table.unpack({
    awful.key({ modkey }, "s",      hotkeys_popup.show_help,
    {description="show help", group="awesome"}),
    awful.key({ modkey}, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Ctrl" }, "Tab", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Shift"}, "Tab", function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end),
    awful.key({ modkey }, "Tab",
    function ()
        awful.client.focus.byidx(1)
        if client.focus then
            client.focus:raise()
        end
    end),
    --
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
    {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "n",
    function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal(
            "request::activate", "key.unminimize", {raise = true}
            )
        end
    end,
    {description = "restore minimized", group = "client"}),
    --
    -- Prompt
    awful.key({ modkey }, "r",     function () awful.screen.focused().mypromptbox:run() end,
    {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "x",
    function ()
        awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
    end,
    {description = "lua execute prompt", group = "awesome"}),
    --
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})
}))

clientkeys = gears.table.join(table.unpack({
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey }, "F4", function (c) c:kill() end, {description = "close", group = "client"}),
    awful.key({ modkey }, "o", function (c) c:move_to_screen() end, {description = "move to screen", group = "client"}),
    awful.key({ modkey }, "n", function (c) c.minimized = true end, {description = "minimize", group = "client"}),
    awful.key({ modkey }, "m", function (c) c.maximized = not c.maximized c:raise() end, {description = "(un)maximize", group = "client"})
}))

clientbuttons = gears.table.join(
awful.button({ }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
end),
awful.button({ modkey }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
end),
awful.button({ modkey }, 3, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
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
        rule_any = { type = { "normal", "dialog" }},
        properties = { titlebars_enabled = true }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if not c.icon then
        c.icon = gears.surface("/home/hung/.config/awesome/defaulticon.svg")._native
    end
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
    local buttons = gears.table.join(table.unpack({
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    }))
    -- client titlebar
    c.titlebar = awful.titlebar(c, {size = dpi(32)})
    -- c.titlebar:connect_signal(
    c.titlebar:setup({
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            -- awful.titlebar.widget.floatingbutton (c),
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
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            -- awful.titlebar.widget.stickybutton   (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    })
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
