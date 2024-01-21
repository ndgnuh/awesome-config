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
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

_G.rrequire = require("rrequire")
_G.ic = require("icecream")
-- ic = function(...) end
_G.resource = function(path)
    return gears.filesystem.get_configuration_dir() .. path
end
local workflow = require("lib.workflow")
workflow.setup()

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local lib = require("lib")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors,
    })
end

-- THE NON_CODE CUSTOMIZED CONFIG
local survival = require("lib.survival")
local settings = require("lib.settings")

--- User level settings
-- this equivalent to the global scope, but it is cached to the file system
settings.load()
settings.default("terminal", "xterm")
settings.default("modkey", "Mod4")

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme = require("ndgnuh.theme")
beautiful.init(theme)
-- beautiful.fg_primary = "#FF-0001"
-- beautiful.bg_primary = "#FF0000"
-- beautiful.font_size_px = 13
-- beautiful.wibar_height = 32
-- beautiful.border_normal = "#000000"
-- beautiful.border_focus = "#000000"

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

function pdump(...)
    local ok, err_or_result = pcall(...)
    if not ok then
        dump({ a_error = err_or_result })
        return nil
    else
        return err_or_result
    end
end

-- local mediakeys = pdump(require, "mediakeys")
-- pdump(abc, 123)
-- dump(beautiful.xresources.get_dpi())

-- swap two screen
local function swap_screen()
    local focused = awful.screen.focused()
    local focused_tag = focused.selected_tag
    local clients = {}
    -- list clients on each one
    for s in screen do
        clients[s] = s.clients
    end

    -- move to the relative screen
    -- since list of client are change, we
    -- have to collect them above
    for _, clients_i in pairs(clients) do
        for _, c in ipairs(clients_i) do
            c:move_to_screen()
        end
    end

    -- focus the currently focused screen
    awful.screen.focus(focused)
    awful.tag.viewidx(focused_tag.index, focused)
    focused_tag:view_only()
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
settings.modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    lib.workflow.layout.max,
    lib.workflow.layout.tile,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    {
        "hotkeys",
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { "manual",      settings.terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    {
        "quit",
        function()
            awesome.quit()
        end,
    },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build {
        before = { menu_awesome },
        after = { menu_terminal }
    }
else
    mymainmenu = awful.menu({
        items = {
            menu_awesome,
            { "Debian", debian.menu.Debian_menu.Debian },
            menu_terminal,
        },
    })
end

-- client action menu
local function span_client(c, cw, ch)
    -- constraint width/height
    cw = cw or false
    ch = ch or true
    c = c or client.focus
    if not c then
        return
    end
    local right_most, left_most, top_most, bottom_most
    local minx, maxx, miny, maxy, minw, minh = 30000, 0, 30000, 0, 30000, 30000
    for s in screen do
        local g = s.geometry
        if g.x > maxx then
            right_most = s
            maxx = g.x
        end
        if g.y > maxy then
            bottom_most = s
            maxy = g.y
        end
        if g.x <= minx then
            left_most = s
            minx = g.x
        end
        if g.y <= miny then
            top_most = s
            miny = g.y
        end
        minw = math.min(s.workarea.width, minw)
        minh = math.min(s.workarea.height, minh)
    end
    local x = left_most.workarea.x
    local y = top_most.workarea.y
    local w = right_most.workarea.x + right_most.workarea.width - x
    local h = right_most.workarea.y + right_most.workarea.height - y
    w = cw and math.min(minw, w) or w
    h = ch and math.min(minh, h) or h
    c.floating = true
    c.ontop = true
    c:geometry({ x = x, y = y, width = w, height = h })
end

local function c_toggle(attr, value)
    return function()
        local c = client.focus
        if c then
            c[attr] = value or not c[attr]
        end
    end
end

local client_action_menu = awful.menu({
    items = {
        { "Span",       span_client },
        {
            "Unspan",
            function()
                c_toggle("floating")()
                c_toggle("ontop")()
            end,
        },
        { "Float",      c_toggle("floating") },
        { "Sticky",     c_toggle("sticky") },
        { "Ontop",      c_toggle("ontop") },
        { "Fullscreen", c_toggle("fullscreen") },
    },
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.container.place(wibox.widget.textclock("%H:%M %a, %d/%m/%Y"))

-- Create a wibox for each screen and add it

local function set_wallpaper(s)
    -- Wallpaper
    local wallpaper = resource("assets/wallpaper.png")
    gears.wallpaper.maximized(wallpaper, s, false)
    -- awful.spawn.with_shell("/home/hung/.fehbg", false)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(screen)
    require("ndgnuh.taglist").setup { screen = screen }
    require("ndgnuh.wibar").setup { screen = screen }
    awful.tag({ 1 }, screen, awful.layout.layouts[1])
    set_wallpaper(screen)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function()
        mymainmenu:toggle()
    end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
ic(settings.modkey)
local mod = { settings.modkey }
local mod_shift = { settings.modkey, "Shift" }
local mod_ctrl = { settings.modkey, "Control" }
globalkeys = gears.table.join(
    awful.key(mod, "a", function()
        awful.spawn("ibus engine anthy", false)
    end),
    awful.key(mod, "v", function()
        awful.spawn("ibus engine Bamboo", false)
    end),
    awful.key(mod, "e", function()
        awful.spawn("ibus engine xkb:us::eng", false)
    end),
    awful.key(mod, "m", function()
        awful.layout.set(lib.workflow.layout.max)
    end, { description = "Set max layout for current tag", group = "tag" }),
    awful.key(mod, "f", function()
        awful.layout.set(awful.layout.suit.floating)
    end, { description = "Max layout for current tag", group = "tag" }),
    awful.key(mod, "t", function()
        awful.layout.set(lib.workflow.layout.tile)
    end, { description = "Tile layout for current tag", group = "tag" }),
    awful.key(mod, "s", function()
        awful.screen.focus_relative(1)
    end, { description = "focus next screen", group = "screen" }),
    awful.key(mod, "Left", workflow.view_previous_tag, { description = "view previous", group = "tag" }),
    awful.key(mod, "Right", workflow.view_next_tag, { description = "view next", group = "tag" }),
    awful.key(mod_shift, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),
    awful.key(mod, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),
    awful.key(mod, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "client" }),
    awful.key(mod, "w", function()
        mymainmenu:show()
    end, { description = "show main menu", group = "awesome" }),
    awful.key(mod_shift, "o", function()
        swap_screen()
    end, { description = "Swap two screen", group = "awesome" }),

    -- Layout manipulation
    awful.key(mod_shift, "j", function()
        -- local taskswitcher = require("widgets.taskswitcher")
        -- local ts = taskswitcher.task_switcher(s)
        -- dump(ts)
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),
    awful.key(mod_shift, "k", function()
        awful.client.swap.byidx(-1)
    end, { description = "swap with previous client by index", group = "client" }),
    awful.key(mod_shift, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key(mod_shift, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),
    awful.key(mod, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
    awful.key(mod, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = "go back", group = "client" }),

    -- Standard program
    awful.key(mod, "Return", function()
        awful.spawn.with_shell(settings.terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key(mod_shift, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
    awful.key(mod_shift, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
    awful.key(mod, "/", hotkeys_popup.show_help, { description = "View all hotkeys", group = "awesome" }),
    awful.key(mod, "0", workflow.view_none, { description = "Show-off wallpaper", group = "tag" }),
    awful.key(mod, "h", workflow.view_previous_tag, { description = "View previous tag", group = "tag" }),
    awful.key(mod, "l", workflow.view_next_tag, { description = "View next tag", group = "tag" }),
    awful.key(mod_shift, "h", workflow.move_to_previous_tag, { description = "Move focused client to next tag" }),
    awful.key(mod_shift, "l", workflow.move_to_next_tag, { description = "Move focused client to previous tag" }),
    awful.key(mod, "space", function() awful.layout.inc(1) end, { description = "select next", group = "layout" }),
    awful.key(mod_shift, "space", function()
        awful.layout.inc(-1)
    end, { description = "select previous", group = "layout" }),
    awful.key(mod_ctrl, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
        end
    end, { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key(mod, "r", function()
        awful.spawn.with_shell(settings.launcher, false)
    end, { description = "run prompt", group = "launcher" }),

    awful.key(mod, "x", function()
        awful.prompt.run({
            prompt = "Run Lua code: ",
            textbox = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval",
        })
    end, { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    awful.key(mod, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ settings.modkey, "Shift" }, "s", function(c)
        c.sticky = not c.sticky
    end, { description = "toggle sticky", group = "client" }),
    awful.key({ settings.modkey, "Shift" }, "f", function(c)
        if not c.fullscreen then
            c.prev_ontop = c.ontop
        end
        c.fullscreen = not c.fullscreen
        if not c.fullscreen then
            c.ontop = c.prev_ontop
        end
        c:raise()
    end, { description = "toggle fullscreen", group = "client" }),
    awful.key(mod, "c", function(c)
        client_action_menu:show()
    end, { description = "action menu", group = "client" }),
    awful.key(mod_shift, "c", function(c)
        c:kill()
    end, { description = "close", group = "client" }),
    awful.key(
        { settings.modkey, "Control" },
        "space",
        awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }
    ),
    awful.key({ settings.modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, { description = "move to master", group = "client" }),
    awful.key(mod, "o", function(c)
        c:move_to_screen()
    end, { description = "move to screen", group = "client" }),
    awful.key(mod_shift, "t", function(c)
        c.ontop = not c.ontop
    end, { description = "toggle keep on top", group = "client" }),
    awful.key({ settings.modkey }, "n", function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end, { description = "minimize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(
        globalkeys,
        -- View tag only.
        awful.key({ settings.modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ settings.modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ settings.modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ settings.modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ settings.modkey, "Shift" }, 1, function(c)
        c.floating = false
    end),
    awful.button({ settings.modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        c.floating = true
        awful.mouse.client.move(c)
    end),
    awful.button({ settings.modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
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
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            maximized = false,
            maximized_horizontal = false,
            maximized_vertical = false,
        },
        callback = function(c)
            awful.client.setslave(c)
        end,
    },

    -- floating sticky
    {
        rule_any = {
            class = {
                "dragon",
                "Dragon",
                "gscreenshot",
                "Gscreenshot",
            },
            name = {
                "Picture-in-Picture",
            },
        },
        properties = {
            floating = true,
            ontop = true,
            sticky = true,
        },
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
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
                "xtightvncviewer",
                "gscreenshot",
                "Gscreenshot",
                "OBS",
                "obs",
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
                "Xephyr",
                "GETAMPED",
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
                "toolbox",       -- toolbox in general?
                "tooltip",       -- toolbox in general?
            },
        },
        properties = {
            ontop = true,
            floating = true,
        },
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = { "normal", "dialog" },
        },
        properties = { titlebars_enabled = false },
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
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
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("tagged", function(c)
    if c.maximized then
        c.maximized = false
        c.maximized_horizontal = false
        c.maximized_vertical = false
    end
end)
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- Enable border for floating clients
client.connect_signal("property::floating", function(c)
    if c.floating then
        c.border_width = beautiful.border_width
    end
end)

-- require("lib.volume")
-- pdump(require, "lib.form_widgets")
if false then
    pdump(require, "draft2")
end
