-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
custom_exit = true
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

require("rc.themes")
require("rc.layouts-and-tags")
require("rc.errorhandle")
require("rc.autostart")
require("rc.globalkeys")
require("rc.rules")

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ "manual", tostring(terminal) .. " -e man awesome" },
	{ "edit config", tostring(editor_cmd) .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ 
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", tostring(terminal) }
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
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

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

local tasklist_buttons = gears.table.join(
awful.button({ }, 1, function (c)
	if c == client.focus then
		c.minimized = true
	else
		c:emit_signal(
		"request::activate",
		"tasklist",
		{raise = true}
		)
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
end))

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

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	

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
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons
	}

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		nil,
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			-- mykeyboardlayout,
			wibox.widget.systray(),
			mytextclock,
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end)
	-- awful.button({ }, 4, awful.tag.viewnext),
	-- awful.button({ }, 5, awful.tag.viewprev)
))
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

	-- awful.titlebar(c) : setup {
	-- 	{ -- Left
	-- 		awful.titlebar.widget.iconwidget(c),
	-- 		buttons = buttons,
	-- 		layout  = wibox.layout.fixed.horizontal
	-- 	},
	-- 	{ -- Middle
	-- 		{ -- Title
	-- 			align  = "center",
	-- 			widget = awful.titlebar.widget.titlewidget(c)
	-- 		},
	-- 		buttons = buttons,
	-- 		layout  = wibox.layout.flex.horizontal
	-- 	},
	-- 	{ -- Right
	-- 		awful.titlebar.widget.floatingbutton (c),
	-- 		awful.titlebar.widget.maximizedbutton(c),
	-- 		awful.titlebar.widget.stickybutton   (c),
	-- 		awful.titlebar.widget.ontopbutton    (c),
	-- 		awful.titlebar.widget.closebutton    (c),
	-- 		layout = wibox.layout.fixed.horizontal()
	-- 	},
	-- 	layout = wibox.layout.align.horizontal
	-- }
	awful.titlebar(c, {position = "left", size=4})
	awful.titlebar(c, {position = "top", size=4})
	awful.titlebar(c, {position = "bottom", size=4})
	awful.titlebar(c, {position = "right", size=4})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--
require("mediakeys")
require("mediapopup")

require("exit")
require("dmenu")
