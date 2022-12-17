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

-- config
local default_config = require("default_config")
local ok, config = pcall(require, "config")
if not ok then
	config = {}
end
for k, v in pairs(default_config) do
	if config[k] == nil then
		config[k] = v
	end
end

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local max_layout = require("max_layout")
-- require("monkey.layout")

-- animation
local throttle = require("lib.throttle")
local has_rubato, rubato = pcall(require, "lib.rubato")
local dualbar = require("widgets.dualbar")
local tile_layout, taglist, tasklist = nil, nil, nil
if has_rubato then
	tile_layout = require("tile_layout")
	taglist = require("widgets.rubato_taglist")
	tasklist = require("widgets.rubato_tasklist")
	-- tile_layout = require("tile_layout_rubato")
else
	tile_layout = require("tile_layout")
	taglist = require("widgets.normal_taglist")
	tasklist = require("widgets.normal_tasklist")
end

-- lol
-- tile_layout.name = "[]="
-- awful.layout.suit.floating.name = "><>"
-- max_layout.name = "[M]"

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
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.border_width = 3
beautiful.master_width_factor = 0.55 -- learn from dwm guys
beautiful.font_size = 12
beautiful.font_size_px = beautiful.font_size * beautiful.xresources.get_dpi() / 71
beautiful.font = "sans " .. beautiful.font_size
beautiful.wibar_height = math.ceil(beautiful.font_size_px * 2)
beautiful.useless_gap = beautiful.font_size_px / 4
beautiful.wibar_width = beautiful.wibar_height
beautiful.menu_width = beautiful.font_size_px * 15
beautiful.menu_height = beautiful.wibar_height
beautiful.taglist_bg_focus = beautiful.bg_focus
beautiful.taglist_bg_normal = beautiful.bg_normal
beautiful.taglist_fg_focus = beautiful.fg_focus
beautiful.taglist_fg_occupied = beautiful.fg_normal
beautiful.taglist_fg_empty = "#444"
-- tasklist
beautiful.tasklist_bg_focus = beautiful.bg_focus
beautiful.tasklist_bg_normal = beautiful.bg_normal
beautiful.tasklist_fg_focus = beautiful.fg_focus
beautiful.tasklist_fg_normal = beautiful.taglist_fg_occupied
beautiful.tasklist_fg_minimize = beautiful.taglist_fg_empty

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

function dump(x)
	x = gears.debug.dump_return(x)
	naughty.notify({
		title = "Debug",
		text = x,
		timeout = 0,
	})
end

function pdump(...)
	local ok, err_or_result = pcall(...)
	if not ok then
		dump({ a_error = err_or_result })
	else
		return err_or_result
	end
end

local mediakeys = pdump(require, "mediakeys")
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
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	max_layout,
	tile_layout,
	awful.layout.suit.floating,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

awful.layout.layouts_ = {
	-- awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
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
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
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
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after = { menu_terminal },
	})
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
		{ "Span", span_client },
		{
			"Unspan",
			function()
				c_toggle("floating")()
				c_toggle("ontop")()
			end,
		},
		{ "Float", c_toggle("floating") },
		{ "Sticky", c_toggle("sticky") },
		{ "Ontop", c_toggle("ontop") },
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
	awful.spawn.with_shell("/home/hung/.fehbg", false)
	-- if beautiful.wallpaper then
	--	local wallpaper = beautiful.wallpaper
	--	-- If wallpaper is a function, call it with the screen
	--	if type(wallpaper) == "function" then
	--		wallpaper = wallpaper(s)
	--	end
	--	gears.wallpaper.maximized(wallpaper, s, true)
	-- end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- short hands
	local x = s.geometry.x
	local y = s.geometry.y
	local w = s.geometry.width
	local h = s.geometry.height
	local bw = beautiful.wibar_width
	local bh = beautiful.wibar_height
	local bg = beautiful.wibar_bg

	-- seperation
	local sep = wibox.widget.textbox("—")

	-- Wallpaper
	-- set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "一", "二", "三", "し", "ご" }, s, awful.layout.layouts[1])
	-- awful.tag({ "一", "二", "三", "し", "ご", "六", "七" }, s, awful.layout.layouts[1])
	-- awful.tag({ 1, 2, 3, 4 }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = wibox.widget({
		widget = wibox.container.background,
		bg = beautiful.bg_focus,
		{
			widget = wibox.container.place,
			forced_height = bh,
			forced_width = bw,
			awful.widget.layoutbox(s),
		},
	})


	s.mylayoutbox:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.layout.inc(1)
	end),
	awful.button({}, 3, function()
		awful.layout.inc(-1)
	end),
	awful.button({}, 4, function()
		awful.layout.inc(1)
	end),
	awful.button({}, 5, function()
		awful.layout.inc(-1)
	end)
	))
	-- Create a taglist widget

	-- Create the wibox
	local clock = wibox.widget({
		widget = awful.widget.textclock,
		font = "monospace",
		format = "%H\n%M",
	})
	clock:connect_signal("button::press", function()
		awful.spawn.with_shell(config.calendar_command, false)
	end)

	local function place(w)
		return wibox.container.place(w)
	end

	s.clock = wibox.widget({
		widget = awful.widget.textclock,
		font = "monospace",
		format = "%H\n%M",
	})
	s.clock:connect_signal("button::press", function()
		awful.spawn.with_shell(config.calendar_command, false)
	end)
	dualbar.setup_hbar(s, {
		layout = wibox.layout.fixed.horizontal,
		s.mylayoutbox,
		tasklist.setup(s),
	})
	dualbar.setup_vbar(s, {
		layout = wibox.layout.align.vertical,
		{
			layout = wibox.layout.fixed.vertical,
			taglist.setup(s, "vertical"),
		},
		nil,
		{
			layout = wibox.layout.fixed.vertical,
			require("widgets.volume_item"),
			{
				widget = wibox.container.place,
				{
					widget = wibox.container.rotate,
					direction = "west",
					{
						widget = wibox.widget.systray,
						screen = s,
						id = "systray",
					},
				},
			},
			wibox.container.place(sep),
			wibox.container.place(s.clock),
		},
	})

	-- rect focus
	-- local ok, rect_focus = pcall(require, "widgets.rect_focus")
	-- if not ok then
	--	dump(rect_focus)
	-- end
	-- rect_focus.disable()
	-- throttle.delayed(0.1, rect_focus.enable)()
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
globalkeys = gears.table.join(
awful.key({ modkey }, "v", function()
	awful.spawn("ibus engine Bamboo", false)
end),
awful.key({ modkey }, "e", function()
	awful.spawn("ibus engine xkb:us::eng", false)
end),
awful.key({ modkey }, "m", function()
	awful.layout.set(max_layout)
end, { description = "Set max layout for current tag", group = "tag" }),
awful.key({ modkey }, "f", function()
	awful.layout.set(awful.layout.suit.floating)
end, { description = "Set max layout for current tag", group = "tag" }),
awful.key({ modkey }, "t", function()
	awful.layout.set(tile_layout)
	-- awful.layout.set(awful.layout.suit.tile.left)
end, { description = "Set max layout for current tag", group = "tag" }),
awful.key({ modkey, "Shift" }, "b", function()
	pdump(awesome.emit_signal, "debug")
end, { description = "show/hide wibar", group = "awesome" }),
awful.key({ modkey }, "b", function()
	local s = awful.screen.focused()
	dualbar.toggle(s)
end, { description = "show/hide wibar", group = "awesome" }),
-- awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
awful.key({ modkey }, "s", function()
	awful.screen.focus_relative(1)
end, { description = "focus next screen", group = "screen" }),
awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
awful.key({ modkey, "Shift" }, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),

awful.key(config.focus_next_key[1], config.focus_next_key[2], function()
	awful.client.focus.byidx(1)
end, { description = "focus next by index", group = "client" }),
awful.key({ modkey }, "k", function()
	awful.client.focus.byidx(-1)
end, { description = "focus previous by index", group = "client" }),
awful.key({ modkey }, "w", function()
	mymainmenu:show()
end, { description = "show main menu", group = "awesome" }),
awful.key({ modkey, "Shift" }, "o", function()
	swap_screen()
end, { description = "Swap two screen", group = "awesome" }),

-- Layout manipulation
awful.key({ modkey, "Shift" }, "j", function()
	-- local taskswitcher = require("widgets.taskswitcher")
	-- local ts = taskswitcher.task_switcher(s)
	-- dump(ts)
	awful.client.swap.byidx(1)
end, { description = "swap with next client by index", group = "client" }),
awful.key({ modkey, "Shift" }, "k", function()
	awful.client.swap.byidx(-1)
end, { description = "swap with previous client by index", group = "client" }),
awful.key({ modkey, "Control" }, "j", function()
	awful.screen.focus_relative(1)
end, { description = "focus the next screen", group = "screen" }),
awful.key({ modkey, "Control" }, "k", function()
	awful.screen.focus_relative(-1)
end, { description = "focus the previous screen", group = "screen" }),
awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
awful.key({ modkey }, "Tab", function()
	awful.client.focus.history.previous()
	if client.focus then
		client.focus:raise()
	end
end, { description = "go back", group = "client" }),

-- Standard program
awful.key({ modkey }, "Return", function()
	awful.spawn.with_shell(config.terminal_command, false)
end, { description = "open a terminal", group = "launcher" }),
awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

awful.key({ modkey }, "l", function()
	awful.tag.incmwfact(0.05)
end, { description = "increase master width factor", group = "layout" }),
awful.key({ modkey }, "h", function()
	awful.tag.incmwfact(-0.05)
end, { description = "decrease master width factor", group = "layout" }),
awful.key({ modkey, "Shift" }, "h", function()
	awful.tag.incnmaster(1, nil, true)
end, { description = "increase the number of master clients", group = "layout" }),
awful.key({ modkey, "Shift" }, "l", function()
	awful.tag.incnmaster(-1, nil, true)
end, { description = "decrease the number of master clients", group = "layout" }),
awful.key({ modkey, "Control" }, "h", function()
	awful.tag.incncol(1, nil, true)
end, { description = "increase the number of columns", group = "layout" }),
awful.key({ modkey, "Control" }, "l", function()
	awful.tag.incncol(-1, nil, true)
end, { description = "decrease the number of columns", group = "layout" }),
awful.key({ modkey }, "space", function()
	awful.layout.inc(1)
end, { description = "select next", group = "layout" }),
awful.key({ modkey, "Shift" }, "space", function()
	awful.layout.inc(-1)
end, { description = "select previous", group = "layout" }),

awful.key({ modkey, "Control" }, "n", function()
	local c = awful.client.restore()
	-- Focus restored client
	if c then
		c:emit_signal("request::activate", "key.unminimize", { raise = true })
	end
end, { description = "restore minimized", group = "client" }),

-- Prompt
awful.key({ modkey }, "r", function()
	awful.spawn.with_shell(config.launcher_command, false)
end, { description = "run prompt", group = "launcher" }),

awful.key({ modkey }, "x", function()
	awful.prompt.run({
		prompt = "Run Lua code: ",
		textbox = awful.screen.focused().mypromptbox.widget,
		exe_callback = awful.util.eval,
		history_path = awful.util.get_cache_dir() .. "/history_eval",
	})
end, { description = "lua execute prompt", group = "awesome" }),
-- Menubar
awful.key({ modkey }, "p", function()
	menubar.show()
end, { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
awful.key({ modkey, "Shift" }, "s", function(c)
	c.sticky = not c.sticky
end, { description = "toggle sticky", group = "client" }),
awful.key({ modkey, "Shift" }, "f", function(c)
	if not c.fullscreen then
		c.prev_ontop = c.ontop
	end
	c.fullscreen = not c.fullscreen
	if not c.fullscreen then
		c.ontop = c.prev_ontop
	end
	c:raise()
end, { description = "toggle fullscreen", group = "client" }),
awful.key({ modkey }, "c", function(c)
	client_action_menu:show()
end, { description = "action menu", group = "client" }),
awful.key({ modkey, "Shift" }, "c", function(c)
	c:kill()
end, { description = "close", group = "client" }),
awful.key(
{ modkey, "Control" },
"space",
awful.client.floating.toggle,
{ description = "toggle floating", group = "client" }
),
awful.key({ modkey, "Control" }, "Return", function(c)
	c:swap(awful.client.getmaster())
end, { description = "move to master", group = "client" }),
awful.key({ modkey }, "o", function(c)
	c:move_to_screen()
end, { description = "move to screen", group = "client" }),
awful.key({ modkey, "Shift" }, "t", function(c)
	c.ontop = not c.ontop
end, { description = "toggle keep on top", group = "client" }),
awful.key({ modkey }, "n", function(c)
	-- The client currently has the input focus, so it cannot be
	-- minimized, since minimized clients can't have the focus.
	c.minimized = true
end, { description = "minimize", group = "client" }),
awful.key({ modkey, "Shift" }, "m", function(c)
	if c.floating then
		c.ontop = false
		c.floating = false
	else
		span_client(c)
	end
end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
	globalkeys,
	-- View tag only.
	awful.key({ modkey }, "#" .. i + 9, function()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end, { description = "view tag #" .. i, group = "tag" }),
	-- Toggle tag display.
	awful.key({ modkey, "Control" }, "#" .. i + 9, function()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end, { description = "toggle tag #" .. i, group = "tag" }),
	-- Move client to tag.
	awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end, { description = "move focused client to tag #" .. i, group = "tag" }),
	-- Toggle tag on focused client.
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
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
awful.button({ modkey, "Shift" }, 1, function(c)
	c.floating = false
end),
awful.button({ modkey }, 1, function(c)
	c:emit_signal("request::activate", "mouse_click", { raise = true })
	c.floating = true
	awful.mouse.client.move(c)
end),
awful.button({ modkey }, 3, function(c)
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
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
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
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				"toolbox", -- toolbox in general?
				"tooltip", -- toolbox in general?
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
--	client.connect_signal("request::titlebars", function(c)
--		-- buttons for the titlebar
--		local buttons = gears.table.join(
--		awful.button({ }, 1, function()
--			c:emit_signal("request::activate", "titlebar", {raise = true})
--			awful.mouse.client.move(c)
--		end),
--		awful.button({ }, 3, function()
--			c:emit_signal("request::activate", "titlebar", {raise = true})
--			awful.mouse.client.resize(c)
--		end)
--		)

--		awful.titlebar(c) : setup {
--			{ -- Left
--			awful.titlebar.widget.iconwidget(c),
--			buttons = buttons,
--			layout  = wibox.layout.fixed.horizontal
--		},
--		{ -- Middle
--		{ -- Title
--		align  = "center",
--		widget = awful.titlebar.widget.titlewidget(c)
--	},
--	buttons = buttons,
--	layout  = wibox.layout.flex.horizontal
-- },
-- { -- Right
-- awful.titlebar.widget.floatingbutton (c),
-- awful.titlebar.widget.maximizedbutton(c),
-- awful.titlebar.widget.stickybutton   (c),
-- awful.titlebar.widget.ontopbutton    (c),
-- awful.titlebar.widget.closebutton    (c),
-- layout = wibox.layout.fixed.horizontal()
--	},
--	layout = wibox.layout.align.horizontal
-- }
-- end)

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

if false then
	local animate = require("lib.animate")

	w = wibox({
		x = 0,
		y = 0,
		width = 100,
		height = 100,
		visible = true,
		ontop = true,
		bg = "#F00",
		widget = wibox.widget({
			widget = wibox.container.background,
			forced_width = 100 - 4,
			forced_height = 100 - 4,
			bg = "#FF0",
			wibox.widget.textbox(""),
		}),
	})

	local animation = animate.animation({
		init = w:geometry(),
		target = {},
		callback = function(self, g, t)
			w:geometry(g)
		end
	})

	wants = {
		{ x = 100, width = 200, height = 100 },
		{ x = 200, width = 200, height = 200 },
		{ x = 300, width = 200, height = 200 },
		{ x = 400, height = 400 },
		{ x = 0, y = 0 },
		-- {x = 100, y = 0, width = 100, height = 100},
		-- {x = 100, y = 100, width = 200, height = 100},
		-- {x = 100, y = 0, width = 100, height = 100},
		-- {x = 10, y = 10, width = 200, height = 200},
		-- {x = 10, y = 10, width = 250, height = 200},
	}
	i = 1
	-- local t_animate = throttle(0.03, animate)
	awesome.connect_signal("debug", function()
		if i > #wants then
			i = 1
		end
		want = wants[i]
		dump(want)
		animation.target = want
		pdump(animation.fire)
		i = i + 1
	end)
end

local callback = throttle.delayed(0.03, function(t)
	-- t = t or awful.tag.selected()
	-- if t.layout.name == "max" then
	--	rect_focus.disable()
	-- elseif t.layout.name == "tile" and #t:clients() < 2 then
	--	rect_focus.disable()
	-- else
	--	rect_focus.enable()
	-- end
	rect_focus.disable()
end)

callback()
screen.connect_signal("tag::history::update", function(s)
	callback()
end)
tag.connect_signal("property::layout", callback)
tag.connect_signal("tagged", callback)
tag.connect_signal("untagged", callback)
-- require("widgets.rect_focus").enable()

-- dump(gears.string.split(package.cpath, ";"))
-- local ltl = require("widgets.lazy_task_list")
-- pdump(awful.popup, {
--	placement = awful.placement.bottom_right,
--	visible = true,
--	ontop = true,
--	bg = "#ff0",
--	widget = ltl({ screen = awful.screen.focused() }),
-- })

awesome.connect_signal("startup", function(...)
	-- for s in screen do
	--	dump(s)
	-- end
	gears.wallpaper.maximized("/home/hung/Pictures/wallpaper/pepe-no-good-wp.png")

	-- wibox { x =100, y = 100, width =100, height=100, visible=true}
end)

require("lib.volume")
