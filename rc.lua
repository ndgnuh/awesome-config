-- somewmrc.lua - Default configuration for somewm (AwesomeWM on Wayland)
--
-- Copy this file to ~/.config/somewm/rc.lua and customize it.
-- Press Mod4+s to see all keybindings.
--
-- Coming from AwesomeWM on X11? See docs/reference/deviations for the Wayland
-- differences (no xprop/xdotool/picom, xkb is compositor-side, etc.). The
-- public Lua API is preserved; X11-specific tooling is what changes.

-- Debug: dump a full traceback for every Lua error. The debug::error signal
-- is emitted from inside the pcall message handler, so the erroring stack is
-- still live here and debug.traceback() can see it.
do
	local log_path = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/somewm-errors.log"
	awesome.connect_signal("debug::error", function(err)
		local tb = debug.traceback(tostring(err), 2)
		local f = io.open(log_path, "a")
		if f then
			f:write(os.date("[%F %T] "), tb, "\n\n")
			f:close()
		end
		io.stderr:write(tb, "\n")
	end)
end

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local sp_wallpaper = require("lib.secondary_wallpaper")

local state = require("state")
require("providers.clients")

--- Allow loading ".so" files from configuration direcetory
do
	local config_dir = gears.filesystem.get_configuration_dir()
	package.cpath = package.cpath .. ";" .. config_dir .. "?.so"
end

ic = require("lib.icecream")
require("monkey_patch.require").patch()
require("monkey_patch")

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification({
		urgency = "critical",
		title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
		message = message,
	})
end)

-- Show notification if we fell back due to X11-specific patterns in user config
if awesome.x11_fallback_info then
	gears.timer.delayed_call(function()
		local info = awesome.x11_fallback_info
		local msg = string.format(
			"Your config was skipped because it contains X11-specific code that "
				.. "won't work on Wayland.\n\n"
				.. "File: %s:%d\n"
				.. "Pattern: %s\n"
				.. "Code: %s\n\n"
				.. "Suggestion: %s\n\n"
				.. "Edit your rc.lua to remove X11 dependencies, then restart somewm.",
			info.config_path or "unknown",
			info.line_number or 0,
			info.pattern or "unknown",
			info.line_content or "",
			info.suggestion or "See somewm migration guide"
		)
		naughty.notification({
			urgency = "critical",
			title = "Config contains X11 patterns - using fallback",
			message = msg,
			timeout = 0,
		})
	end)
end

-- Theme
beautiful.init(require("ndgnuh.theme"))

-- Setup the menu/launcher with an "s" instead of AwesomeWM's "a".
-- Same blocky style as beautiful.theme_assets.gen_awesome_name (the "s" letter
-- is letter 3 in the "awesome" wordmark): a square filled with `fg`, with two
-- thin horizontal cuts in `bg` at y=1/3 (right two-thirds) and y=2/3 (left
-- two-thirds).
do
	local cairo = require("lgi").cairo
	local size = beautiful.menu_height
	local fg = beautiful.wallpaper_logo_color or beautiful.fg_focus
	local bg = beautiful.wibar_bg or beautiful.bg_normal

	local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
	local cr = cairo.Context(img)
	cr:set_line_width(size / 18)

	cr:set_source(gears.color(fg))
	cr:rectangle(0, 0, size, size)
	cr:fill()

	if bg then
		cr:set_source(gears.color(bg))
	else
		cr:set_operator(cairo.Operator.CLEAR)
	end
	cr:move_to(size / 3, size / 3)
	cr:rel_line_to(size * 2 / 3, 0)
	cr:stroke()
	cr:move_to(0, size * 2 / 3)
	cr:rel_line_to(size * 2 / 3, 0)
	cr:stroke()
	cr:set_operator(cairo.Operator.OVER)

	beautiful.awesome_icon = img
end

-- Lockscreen (must be after beautiful.init)
require("lockscreen").init()
require("somewm.inspector")
local somewm = require("somewm")

-- Defaults
-- Change these to your preferred terminal and editor, or use xdg-terminal and xdg-editor if available.
local terminal = "sakura"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local modkey = "Mod4"

-- ============================================================
-- User customization (uncomment to enable)
-- ============================================================
require("ndgnuh.input_config")

-- Autostart (idempotent across reloads).
local survival = require("lib.survival")
survival.spawn.once("ibus-daemon -rd --panel disable")
survival.spawn.once("network-manager-applet")
survival.spawn.once("blueman-applet") -- bluetooth tray
survival.spawn.once("udiskie --tray") -- auto-mount removable drives

-- Init functional modules
local ibus = require("lib.ibus")
gears.timer.delayed_call(function()
	ibus:init()
end)

-- Auto-lock after N seconds of idle.
-- awesome.set_idle_timeout("auto-lock", 600, function() awesome.lock() end)

-- Inhibit idle while presenting / watching a long video. Combines with
-- protocol-level inhibitors (mpv, browsers); see awesome.idle_inhibited
-- for the OR'd state.
-- awful.keyboard.append_global_keybindings({ awful.key {
--     modifiers = { modkey, "Shift" }, key = "i",
--     on_press = function() awesome.idle_inhibit = not awesome.idle_inhibit end,
--     description = "toggle idle inhibit", group = "awesome",
-- } })

-- Animated layout transitions (somewm-specific). Tiled clients fly smoothly
-- between positions on layout changes, mwfact tweaks, client spawn/close, etc.
-- local layout_anim = require("somewm.layout_animation")
-- layout_anim.duration = 0.15
-- layout_anim.easing   = "ease-out-cubic"

-- Custom IPC commands. After reload, callable as:
--   somewm-client run focused-tag
-- awful.ipc.register("focused-tag", function()
--     local t = awful.screen.focused().selected_tag
--     return t and t.name or ""
-- end)

-- Menu
local theme_menu = {
	{
		"gruvbox",
		function()
			switch_theme("gruvbox")
		end,
	},
	{
		"catppuccin",
		function()
			switch_theme("catppuccin")
		end,
	},
	{
		"nord",
		function()
			switch_theme("nord")
		end,
	},
}

local menu_items = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{
		"terminal",
		function()
			awful.spawn(terminal)
		end,
	},
	-- { "theme", theme_menu },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"lock",
		function()
			awesome.lock()
		end,
	},
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "somewm", menu_items, beautiful.awesome_icon },

		{
			"Change wallpaper",
			function()
				sp_wallpaper:pick_wallpaper()
			end,
		},
		{
			"Toggle inspector (SomeWM 2.1)",
			function()
				somewm.inspector.toggle()
			end,
		},
		require("lib.do_not_disturb").menuitem,
		require("lib.reload_theme").menuitem,
		require("lib.split").menuitem,
		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

require("ndgnuh.mainmenu")

awesome.connect_signal("show-launcher", function()
	mylauncher:run()
end)

menubar.utils.terminal = terminal

-- Layouts
-- Signal-driven layout registration. Fires once at startup; config code appends
-- to the layouts list so multiple chunks (defaults + user additions) can compose.
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		awful.layout.suit.max,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.carousel,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.corner.nw,
		awful.layout.suit.floating,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
	})
end)

-- Wallpaper
screen.connect_signal("request::wallpaper", function(s)
	local colors = beautiful.wallpaper_colors
	if colors then
		local dpi = beautiful.xresources.apply_dpi
		local logo_size = dpi(200)
		local logo_color = beautiful.wallpaper_logo_color
		local logo_path = gears.filesystem.get_themes_dir() .. "../icons/somewm-logo.svg"

		-- Recolor logo to match theme
		local logo_widget = nil
		if logo_color then
			local logo_image = gears.color.recolor_image(logo_path, logo_color)
			logo_widget = {
				{
					image = logo_image,
					forced_height = logo_size,
					forced_width = logo_size,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				halign = "center",
				widget = wibox.container.place,
			}
		end

		awful.wallpaper({
			screen = s,
			bg = {
				type = "linear",
				from = { 0, 0 },
				to = { s.geometry.width, s.geometry.height },
				stops = { { 0, colors[1] }, { 1, colors[2] } },
			},
			widget = logo_widget,
		})
	elseif beautiful.wallpaper and s == screen.primary then
		awful.wallpaper({
			screen = s,
			widget = {
				{
					image = beautiful.wallpaper,
					upscale = true,
					downscale = true,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				halign = "center",
				tiled = false,
				widget = wibox.container.tile,
			},
		})
	else
		local wp = require("lib.secondary_wallpaper")
		wp.set_wallpaper(s)
		-- awful.wallpaper({ screen = s, bg = beautiful.bg_normal or "#222222" })
	end
end)

-- Tag persistence across monitor hotplug
-- The save handler lives in awful.permissions.tag_screen and stores tag
-- metadata into awful.permissions.saved_tags keyed by connector name.
-- To disable or replace it:
--   tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

-- Wibar

local mytextclock = wibox.widget({
	{
		{
			format = "%a %b %d  %H:%M",
			widget = wibox.widget.textclock,
		},
		left = dpi(8),
		right = dpi(8),
		widget = wibox.container.margin,
	},
	bg = beautiful.clock_bg or beautiful.bg_focus,
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(4))
	end,
	widget = wibox.container.background,
})

-- Fires once per screen at startup AND on monitor hotplug. Restore saved tags
-- if this connector was previously seen; otherwise create the default set.
screen.primary.scale = 1.25
screen.connect_signal("request::desktop_decoration", function(s)
	-- Restore saved tags if this output was previously removed
	awful.tag({ 1 }, s, awful.layout.layouts[1])

	-- Enable wibar only on the primary screen

	if s == screen.primary then
		local wibar = require("ndgnuh.wibar")(s)
		awesome.connect_signal("wibar:toggle", function()
			wibar.visible = not wibar.visible
			if wibar.visible then
				naughty.notification({
					title = "Wibar",
					message = "Show wibar",
				})
			else
				naughty.notification({
					title = "Wibar",
					message = "Wibar is hidden",
				})
			end
		end)
	end
end)

-- Mouse bindings
awful.mouse.append_global_mousebindings({
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewprev),
	awful.button({}, 5, awful.tag.viewnext),
})

-- Key bindings
awful.keyboard.append_global_keybindings({
	-- awful.key({
	-- 	modifiers = { modkey },
	-- 	key = "s",
	-- 	on_press = hotkeys_popup.show_help,
	-- 	description = "show help",
	-- 	group = "somewm",
	-- }),
	-- awful.key({
	-- 	modifiers = { modkey, "Shift" },
	-- 	key = "Escape",
	-- 	on_press = function()
	-- 		awesome.lock()
	-- 	end,
	-- 	description = "lock screen",
	-- 	group = "somewm",
	-- }),
})

-- Key bindings
require("ndgnuh.keybindings")

-- Client mouse bindings registered via signal so user code can append to the
-- defaults. The same pattern repeats below for keybindings and rules.
client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({
			modifiers = { modkey },
			key = "f",
			on_press = function(c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			description = "toggle fullscreen",
			group = "client",
		}),
		awful.key({
			modifiers = { modkey, "Shift" },
			key = "c",
			on_press = function(c)
				c:kill()
			end,
			description = "close",
			group = "client",
		}),
		awful.key({
			modifiers = { modkey, "Control" },
			key = "space",
			on_press = function(c)
				c.floating = not c.floating
			end,
			description = "toggle floating",
			group = "client",
		}),
		awful.key({
			modifiers = { modkey, "Control" },
			key = "Return",
			on_press = function(c)
				c:swap(awful.client.visible(c.screen)[1])
			end,
			description = "move to master",
			group = "client",
		}),
		awful.key({
			modifiers = { modkey },
			key = "o",
			on_press = function(c)
				c:move_to_screen()
			end,
			description = "move to screen",
			group = "client",
		}),
		-- awful.key({
		-- 	modifiers = { modkey },
		-- 	key = "t",
		-- 	on_press = function(c)
		-- 		c.ontop = not c.ontop
		-- 	end,
		-- 	description = "toggle keep on top",
		-- 	group = "client",
		-- }),
		awful.key({
			modifiers = { modkey },
			key = ",",
			on_press = function(c)
				c.sticky = not c.sticky
			end,
			description = "toggle sticky (show on all tags)",
			group = "client",
		}),
	})
end)

-- Rules
-- Client rules are appended via signal. `rule`/`rule_any` matches client
-- properties; `properties` is the defaults table applied on match.
require("ndgnuh.rules")

-- Titlebars
client.connect_signal("request::titlebars", function(c)
	local buttons = {
		awful.button({}, 1, function()
			c:activate({ context = "titlebar", action = "mouse_move" })
		end),
		awful.button({}, 3, function()
			c:activate({ context = "titlebar", action = "mouse_resize" })
		end),
	}

	awful.titlebar(c).widget = {
		{
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{
			{
				halign = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	}
end)

-- Notifications
-- Notification rules use the same append-via-signal pattern as client rules.
-- Match on app_name/title/urgency/category, set bg/fg/timeout/ignore/etc.
ruled.notification.connect_signal("request::rules", function()
	ruled.notification.append_rule({
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
		},
	})

	-- Per-app routing example: mute one app, bump urgency for another.
	-- ruled.notification.append_rule {
	--     rule       = { app_name = "Spotify" },
	--     properties = { ignore = true },
	-- }
	-- ruled.notification.append_rule {
	--     rule       = { app_name = "Slack", title = "@you" },
	--     properties = { urgency = "critical" },
	-- }
end)

---@param n naughty.notification The notification to display
naughty.connect_signal("request::display", function(n)
	naughty.layout.box({ notification = n })
end)

-- Sloppy focus (focus follows mouse)
client.connect_signal("mouse::enter", function(c)
	c:activate({ context = "mouse_enter", raise = false })
end)
