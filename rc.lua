pcall(require, "luarocks.loader")
local xr = require("beautiful.xresources")
local dpi = xr.apply_dpi
function xr.apply_dpi(x)
	return dpi(x)
end

local myown = require("myown")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local widget = wibox.widget
local layout = wibox.layout
local container = wibox.container
local shape = gears.shape
local unpack = unpack or table.unpack
local root = _G.root
local awesome = _G.awesome
local client = _G.client
local mod = "Mod4"
require("awful.autofocus")
local lgi = require("lgi")
local gdk = lgi.require('Gdk', '3.0')
local gtk = lgi.require('Gtk', '3.0')

function dump(x)
	local content = gears.debug.dump_return(x)
	-- local f = io.open("/tmp/awesome-debug.txt", "w")
	-- f:write(content)
	-- f:close()
	return naughty.notify {timeout = 0, title = "Debug", text = content}
end

-- dump(awesome.systray())

-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- beautiful.init("/home/hung/.config/awesome/myown/theme/init.lua")
beautiful.init(require("myown.theme.pastel"))
-- beautiful.init(require("themes.firefox"))
-- dump(beautiful.gtk)

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err)
		})
		in_error = false
	end)
end

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.max,
	awful.layout.suit.floating
}

-- [[ menu ]]
local menu = myown.menu {
	items = {
		{[[<span font-desc="Bold" foreground=']] .. beautiful.fg_focus .. [[' size="x-large">Application</span>]], align="center", ""},
		{"Web Browser", "firefox"},
		{"File manager", "thunar"},
		{"Screenshot", "screengrab"},
		{
			"Creative tools",
			{
				{"Inkscape", "inkscape"},
				{"Kdenlive", "kdenlive"},
				{"Blender", "blender"},
				{"Krita", "krita"},
				{"GIMP", "gimp"},
			}
		},
		{"Libreoffice", "libreoffice"},
		{
			"System utilities",
			{
				{"Terminal", "qterminal"},
				{"Resource monitor", "qterminal -e htop"},
				{"Appearance", "lxappearance"},
				{"Bluetooth", "blueman-manager"},
			}
		},
		{[[<span font-desc="Bold" foreground=']] .. beautiful.fg_focus .. [[' size="x-large">Session</span>]], align="center", ""},
		{"Lock", "xscreensaver-command -lock"},
		{"Refresh", awesome.restart },
		{"Quit", function() awesome.quit() end },
		{"Cancel", ""},
	}
}


-- [[ binding ]]

local rootbuttons = {
	awful.button({}, 1, awesome.restart),
	awful.button({}, 3, function() awful.spawn("qterminal", false) end)
}
root.buttons(gears.table.join(unpack(rootbuttons)))

awful.screen.connect_for_each_screen(function(s)
	-- tags
	awful.tag({1,2,3,4,5}, s, awful.layout.suit.tile)

	-- wallpapers
	-- gears.wallpaper.set("#626262", s)
	-- gears.wallpaper.set("#626262", s)
	-- awful.spawn.easy_async_with_shell("echo", function()
	--	gears.wallpaper.set("#626262", s)
	-- end)
	gears.wallpaper.fit("/home/hung/Pictures/wallpaper/index", s)
	-- awesome-client 'for s in screen do require("gears").wallpaper.fit("/home/hung/Pictures/wallpaper/index", s) end'

	--	s.bar = awful.wibar{
	--		position = "left",
	--		screen = s,
	--	}

	--	s.layoutbox = awful.widget.layoutbox(s)
	--	s.taglist = myown.widget.taglist(s)

	--	s.bar:setup{
	--		widget = layout.align.vertical,
	--		{
	--			widget = layout.fixed.vertical,
	--			{
	--				buttons = gears.table.join(
	--				awful.button({}, 1, function() awful.layout.inc(1) end),
	--				awful.button({}, 3, function() awful.layout.inc(-1) end)
	--				),
	--				widget = container.margin,
	--				top = 5,
	--				left = 2,
	--				right = 2,
	--				{
	--					widget = container.background,
	--					-- shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 5) end,
	--					shape = myown.shape.squircle,
	--					bg = beautiful.layoutbox_bg,
	--					{
	--						widget = container.margin,
	--						margins = 2,
	--						bottom = 2,
	--						s.layoutbox,
	--					}
	--				}
	--			}
	--		},
	--		-- tag list
	--		s.taglist,
	--		{
	--			widget = layout.fixed.vertical,
	--			spacing = 10,
	--			-- systray
	--			{
	--				widget = container.margin,
	--				margins = 2,
	--				{
	--					widget = container.background,
	--					shape = shape.rounded_rect,
	--					bg = beautiful.bg_systray,
	--					{
	--						widget = container.margin,
	--						top = 15,
	--						bottom = 15,
	--						{
	--							widget = container.rotate,
	--							widget.systray(),
	--							direction = "west"
	--						}
	--					}
	--				}
	--			},
	--			-- clock
	--			{
	--				widget = container.place,
	--				{
	--					widget = widget.textclock,
	--					format = "<span color='#FFF'><b>%H\n%M</b></span>",
	--					font = "monospace 14",
	--					buttons = awful.button({}, 1, function()
	--						awful.spawn("gsimplecal", false)
	--					end)
	--				},
	--			},
	--			widget.textbox(), -- for extra spacing
	--		},
	--	}
end)

local globalkeys = {
	awful.key({mod, "Control"}, "r", awesome.restart),
	awful.key({mod, "Shift"}, "r", awesome.restart),
	awful.key({mod, "Shift"}, "e", awesome.quit),
	awful.key({mod}, "s", function() awful.screen.focus_relative(1) end),
	awful.key({mod}, "w", function()
		-- local children = menu.layout:get_children()
		-- for i, c in ipairs(children) do
		-- end
		menu:show()
	end),

	awful.key({mod, "Shift"}, "space", function() awful.layout.inc(1) end),
	awful.key({mod}, "j", function() awful.client.focus.byidx(1) end),
	awful.key({mod}, "k", function() awful.client.focus.byidx(-1) end),
	awful.key({mod}, "Tab", function()
		awful.client.focus.history.previous()
		local c = client.focus
		if c then c:raise() end
	end),
	awful.key({mod, "Shift"}, "j", function() awful.client.swap.byidx(1) end),
	awful.key({mod, "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({mod, "Shift"}, "n", function()
		local c = awful.client.restore()
		if c then c:emit_signal("request::activate", "key.unminimize", {raise=true}) end
	end),

	awful.key({mod}, "Return", function() awful.spawn("qterminal", false) end),
	awful.key({mod}, "r", function() require("menubar").show() end),
	-- awful.key({mod}, "r", function() awful.spawn.with_shell("rofi -show run", false) end),
	awful.key({mod}, "space", function() awful.spawn.with_shell("echo 'xkb:us::eng\nBamboo' | grep -v $(ibus engine) | xargs -I {} ibus engine '{}'") end),
	awful.key({mod}, "F1", function() awful.spawn("playerctl play-pause", false) end),
	awful.key({mod}, "F2", function() awful.spawn("playerctl previous", false) end),
	awful.key({mod}, "F3", function() awful.spawn("playerctl next", false) end),

	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false) end),
	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false) end),
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false) end),
	-- awful.key({}, "XF86AudioMute", function() awful.spawn("pamixer -t", false) end),
	-- awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 5 --allow-boost", false) end),
	-- awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 5 --allow-boost", false) end),
	awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("xbacklight +10", false) end),
	awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("xbacklight -10", false) end),
	awful.key({}, "XF86Display", function() awful.spawn("arandr", false) end),
	awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause", false) end),
	awful.key({}, "XF86AudioStop", function() awful.spawn("playerctl stop", false) end),
	awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous", false) end),
	awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next", false) end),
}
for i = 1,10 do
	table.insert(globalkeys, awful.key({mod}, "#" .. (i + 9), function()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end))
	table.insert(globalkeys, awful.key({mod, "Shift"}, "#" .. (i + 9), function()
		local c = _G.client.focus
		if not c then return end
		local screen = awful.screen.focused()
		local t = screen.tags[i]
		if not t then return end
		c:move_to_tag(t)
	end))
	table.insert(globalkeys, awful.key({mod, "Ctrl"}, "#" .. (i + 9), function()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end))
end
globalkeys = gears.table.join(unpack(globalkeys))
root.keys(globalkeys)


local clientkeys = {
	awful.key({mod, "Shift"}, "q", function(c) c:kill() end);
	awful.key({mod, "Shift"}, "c", function(c) c:kill() end);
	awful.key({mod}, "m", function(c) c.maximized = not c.maximized end);
	awful.key({mod}, "f", function(c) c.fullscreen = not c.fullscreen end);
	awful.key({mod}, "t", function(c) c.ontop = not c.ontop end);
	awful.key({mod, "Shift"}, "s", function(c) c.sticky = not c.sticky end);
	awful.key({mod, "Shift"}, "f", function(c) c.floating = not c.floating end);
	awful.key({mod}, "n", function(c) c.minimized = true end);
	awful.key({mod}, "o", function(c) c:move_to_screen() end);
}
clientkeys = gears.table.join(unpack(clientkeys))

local clientbuttons = {
	awful.button({mod}, 1, myown.client.move),
	awful.button({mod}, 3, function(c)
		awful.mouse.client.resize(c)
	end),
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
	end),
	awful.button({mod, "Shift"}, 1, myown.client.reset),
	awful.button({mod}, 2, myown.client.reset),
}
clientbuttons = gears.table.join(unpack(clientbuttons))

awful.rules.rules = {
	{
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			titlebars_enabled = true
		}
	},

	{
		-- on top and sticky
		rule_any = {
			name = {"Picture-in-Picture", "ScreenGrab"},
			role = {"toolbox", "utilities"},
			type = {"dialog"}
		},
		properties = {
			ontop = true,
			sticky = true,
			floating = true,
			focus = false
		},
	},

	{
		-- floating
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry"
			},
			class = {
				"Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
				"Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui", "veromix", "Gscreenshot", "xtightvncviewer",
				"PikoPixel"
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
				"pavucontrol",
			},
			type = {"utility", "override"},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				"tooltip"
			}
		},
		properties = {floating = true}
	},
}

beautiful.titlebar_setup = beautiful.titlebar_setup or function(c)
	c.ttb = awful.titlebar(c, {position = "top"})
	local buttons = {
		awful.button({}, 1, function() awful.mouse.client.move(c) end),
		awful.button({}, 2, function() myown.client.reset(c) end),
		awful.button({}, 3, function() awful.mouse.client.resize(c) end),
	}
	buttons = gears.table.join(unpack(buttons))

	local gtk = beautiful.gtk.get_theme_variables()

	local function create_button(color, cb)
		local bg = beautiful.titlebar_fg_normal
		local btn = wibox.widget {
			widget = container.margin,
			top = 4,
			bottom = 4,
			{
				widget = container.background,
				shape = function(cr, w, h)
					local s = math.min(w, h)
					cr:translate(w / 2 - s / 2, h / 2 - s / 2)
					myown.shape.star(cr, s, s, 5)
				end,
				bg = bg,
				forced_width = 32,
				forced_height = 32,
				widget.textbox("")
			}
		}

		btn:connect_signal("mouse::enter", function()
			btn.children[1].bg = color
		end)
		btn:connect_signal("mouse::leave", function()
			btn.children[1].bg = bg
		end)
		btn:connect_signal("button::press", function()
			cb(c)
		end)

		return btn
	end

	c.ttb:setup {
		layout = layout.align.horizontal,
		{
			widget = container.margin,
			awful.widget.clienticon(c),
		},
		{
			widget = container.place,
			buttons = buttons,
			awful.titlebar.widget.titlewidget(c),
		},
		{
			layout = layout.fixed.horizontal,
			awful.titlebar.widget.floatingbutton (c),
			awful.titlebar.widget.stickybutton   (c),
			awful.titlebar.widget.ontopbutton    (c),
			awful.titlebar.widget.minimizebutton (c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton    (c),
			-- create_button(gtk.warning_bg_color, function(c)
			--	c.minimized = false
			--	c.minimized = not c.minimized
			-- end),
			-- create_button(gtk.selected_bg_color, function() c.maximized = not c.maximized end),
			-- create_button(gtk.error_bg_color, function() c:kill() end),
		}
	}
end
client.connect_signal("request::titlebars", beautiful.titlebar_setup)

-- awesome tool
-- checkout at https://github.com/cytopia/autorunner
awful.spawn.with_shell("autorunner", false)

--[ SIGNALS ]

client.connect_signal("mouse::enter", function(c)
	-- sloppy focus follow mouse
	client.focus = c
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

local function make_border_dwim(t)
	-- use this because there might be multiple tag selected
	local cs = t.screen.clients
	local border = {}

	-- because maximized and fullscreen client
	-- are considered floating
	local function truefloat(c)
		return c.floating and (not c.maximized) and (not c.fullscreen)
	end

	-- TODO: look up table instead of ifelse
	if t.layout.name == "max" then
		for _, c in ipairs(cs) do
			if truefloat(c) then
				border[c] = true
			else
				border[c] = false
			end
		end
	elseif t.layout.name == "floating" then
		for _, c in ipairs(cs) do
			if c.maximized or c.fullscreen then
				border[c] = false
			else
				border[c] = true
			end
		end
	else
		local count = 0
		local only = nil
		for _, c in ipairs(cs) do
			if truefloat(c) then
				border[c] = true
			elseif c.maximized or c.fullscreen or c.minimized then
				border[c] = false
			else
				count = count + 1
				only = c
				border[c] = true
			end
		end
		if count == 1 then
			border[only] = false
		end
	end

	local count_noborder = 0
	for c, bd in pairs(border) do
		if bd then
			c.border_width = beautiful.border_width
			c.shape = beautiful.client_shape
		else
			count_noborder = count_noborder + 1
			c.shape = shape.rectangle
			c.border_width = 0
		end
	end
	if count_noborder > 0 then
		beautiful.useless_gap = 0
	else
		beautiful.useless_gap = 3
	end
end


local function make_border_dwim_screen_wrapper(s)
	local t = s.selected_tag
	-- no tag selected
	if t == nil then return end
	make_border_dwim(t)
end

local function make_border_dwim_client_wrapper(c)
	-- don't use c.first_tag or c.tags because unmanaged client have no tag
	-- so if either of those used, in a tile layout
	-- when a client is killed and there is one left, the border will still be there
	local s = c.screen
	if s then make_border_dwim_screen_wrapper(s) end
end

client.connect_signal("tagged", make_border_dwim_client_wrapper)
client.connect_signal("untagged", make_border_dwim_client_wrapper)
client.connect_signal("unmanage", make_border_dwim_client_wrapper)
client.connect_signal("property::floating", make_border_dwim_client_wrapper)
client.connect_signal("property::maximized", make_border_dwim_client_wrapper)
client.connect_signal("property::fullscreen", make_border_dwim_client_wrapper)
client.connect_signal("property::minimized", make_border_dwim_client_wrapper)
tag.connect_signal("property::layout", make_border_dwim)
screen.connect_signal("tag::history::update", make_border_dwim_screen_wrapper)

--[[ collect garbage ]]
gears.timer {
	timeout = 300,
	callback = function()
		collectgarbage("step", 1024)
	end
}:start()

--[[ volume popup ]]
local im = require("images")
local volume_popup = awful.popup{
	ontop = true,
	visible = false,
	placement = awful.placement.centered,
	shape = beautiful.client_shape,
	widget = widget {
		widget = container.margin,
		margins = beautiful.useless_gap * 2,
		{
			widget = container.background,
			{
				widget = layout.fixed.vertical,
				spacing = beautiful.useless_gap,
				{
					widget = widget.imagebox,
					clip_shape = function(cr, w, h) shape.rounded_rect(cr, w, h, 5) end,
					id = 'cat',
					image = im("popcat/audio-volume-muted-symbolic.svg"),
					forced_width = 124,
					forced_height = 124
				},
				{
					widget = layout.stack,
					{
						widget = widget.progressbar,
						id = "bar",
						value = 70,
						max_value = 200,
						min_value = 0,
						shape = function(cr, w, h) shape.rounded_rect(cr, w, h, dpi(5)) end,
						forced_width = 124,
						forced_height = 24,
					},
					{
						widget = widget.textbox,
						id = "text",
						align = "center",
					}
				}
			}
		}
	}
}

local handles = {}
local handle_volume = function()
	cmd = "pamixer --get-volume-human"
	-- cmd = "pactl list sinks  | grep Volume | grep '[[:digit:]]\\+%' -o | head -n 1"
	awful.spawn.easy_async_with_shell(cmd, function(o, e)
		o = o:gsub("\n", "")
		local bar = volume_popup.widget:get_children_by_id("bar")[1]
		local text = volume_popup.widget:get_children_by_id("text")[1]
		local cat = volume_popup.widget:get_children_by_id("cat")[1]
		if o == "muted" then
			bar.value = 0
			text:set_markup("<span color='#fff'>muted</span>")
			cat.image = im("popcat/audio-volume-muted-symbolic.svg")
		else
			text:set_markup("<span color='#fff'>" .. o .. "</span>")
			o = o:gsub("%%", '')
			o = tonumber(o)
			bar.value = o
			if o <= 0 or nil then
				cat.image = im("popcat/audio-volume-muted-symbolic.svg")
			elseif o <= 40 then
				cat.image = im("popcat/audio-volume-low-symbolic.svg")
			elseif o <= 80 then
				cat.image = im("popcat/audio-volume-medium-symbolic.svg")
			elseif o <= 100 then
				cat.image = im("popcat/audio-volume-high-symbolic.svg")
			else
				cat.image = im("popcat/audio-volume-overamplified-symbolic.svg")
			end
		end
		volume_popup.visible = true
	end)
end
handles["XF86AudioLowerVolume"] = handle_volume
handles["XF86AudioRaiseVolume"] = handle_volume
handles["XF86AudioMute"] = handle_volume

key.connect_signal("press", function(k)
	local name = k.key
	local f = handles[k.key]
	if f then f() end
end)
local timer = gears.timer{
	timeout = 1,
	callback = function()
		volume_popup.visible = false
	end,
	single_shot = true
}
key.connect_signal("release", function(k)
	local name = k.key
	if name == "XF86AudioRaiseVolume" or name == "XF86AudioLowerVolume" or name == "XF86AudioMute" then
		timer:again()
	end
end)

-- key.connect_signal("property::key", dump)
-- key.connect_signal("property::modifiers", dump)

-- kill all pipewire process when exit
-- sometime the process persists between logins, causes pamixer and pavucontrol to fail
-- awesome.connect_signal("exit", function(isrestart)
--	if not isrestart then
--		awful.spawn.with_shell("killall -r pipewire -9", false)
--	end
-- end)

require("myown.wavybar")
-- wibox {
--	x = 100, y = 100,
--	width = 32, height = 400,
--	widget = widget {
--		widget = container.background,
--		shape = function(cr, w, h)
--			local s = h * 0.2

--			cr:move_to(0, 0)
--			cr:line_to(w, 0)
--			cr:line_to(w, h-s)
--			cr:curve_to(-s/3, h-s/3, w + s/3, h-s/3*2, 0, h)
--			cr:close_path()
--		end,
--		bg = "#FFF"
--	},
--	ontop= true,
--	visible =true
-- }
