local awful = require("awful")
local gears = require("gears")
local client_api = require("lib.client_api")
local ibus = require("lib.ibus")
local ic = require("lib.icecream")
local client_menu = require("lib.floating_client_menu")
local manual_focus_group = require("ndgnuh.manual_focus_group")
local runprompt = require("ndgnuh.runprompt")
local somewm = require("somewm")

local current_tag

-- Required for focus groups
local spawn_or_cycle = require("lib.spawn_or_cycle")

local function partial(f, x1, x2)
	return function()
		return f(x1, x2)
	end
end

-- Screenshot keybindings
local take_screenshot = require("lib.screenshot")

local modkey = "Mod4"

local keys = {
	awful.key({
		modifiers = {},
		key = "Print",
		on_press = take_screenshot,
		description = "Screenshot (fullscreen)",
		group = "Screenshot",
	}),
	awful.key({
		modifiers = { "Shift" },
		key = "Print",
		on_press = function()
			take_screenshot({ interactive = true })
		end,
		description = "Screenshot (interactive)",
		group = "Screenshot",
	}),
	awful.key({
		modifiers = { "Control" },
		key = "Print",
		on_press = function()
			take_screenshot({ client = client.focus, active_client = true })
		end,
		description = "Screenshot (interactive)",
		group = "Screenshot",
	}),

	--- Inspect current focused client
	awful.key({
		modifiers = { modkey },
		key = "i",
		on_press = function()
			client_api.inspect(client.focus)
		end,
	}),
	awful.key({
		modifiers = { modkey, "Shift" },
		key = "i",
		on_press = function()
			somewm.inspector.toggle()
		end,
	}),

	--- Hot keys for Ibus's engines
	awful.key({
		modifiers = { modkey },
		key = "e",
		on_press = partial(ibus.set_engine, ibus, "xkb:us::eng"),
	}),
	awful.key({
		modifiers = { modkey },
		key = "v",
		on_press = partial(ibus.set_engine, ibus, "Bamboo"),
	}),
	awful.key({
		modifiers = { modkey },
		key = "a",
		on_press = partial(ibus.set_engine, ibus, "anthy"),
	}),

	-- Multiple monitor shortcuts
	awful.key({
		modifiers = { modkey },
		key = "s",
		on_press = function()
			awful.screen.focus_relative(1)
		end,
		description = "Move focus to another screen",
		group = "Screen",
	}),
	awful.key({
		modifiers = { modkey },
		key = "o",
		on_press = function(c)
			-- Move the client to next screen
			-- Keep the client in focus,
			-- Move it to volatile so it does not
			-- Stack with previous clients in there
			c:move_to_screen()
			gears.timer.delayed_call(function()
				awful.client.normalize(c)
				awful.client.focus_globally(c)
				awful.client.move_to_volatile(c)
			end)
		end,
		description = "Move the focused client to another screen",
		group = "Screen",
	}),

	-- Focus related
	awful.key({
		modifiers = { modkey },
		key = "Tab",
		on_press = function()
			client_api.global_focus_previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		description = "Focus on the previously focused client",
		group = "Client",
	}),

	--- terminal
	awful.key({
		modifiers = { modkey },
		key = "Return",
		on_press = function()
			awful.spawn("sakura")
		end,
	}),

	--- Focus groups
	awful.key({
		modifiers = { modkey },
		key = "1",
		on_press = spawn_or_cycle({
			command = "sakura",
			class = { "sakura", "terminal" },
		}),
		description = "Terminal (sakura)",
		application = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "2",
		on_press = spawn_or_cycle({
			command = "firefox-devedition",
			class = { "firefox-dev", "firefox", "chromium" },
		}),
		description = "Browser",
		application = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "4",
		on_press = spawn_or_cycle({
			command = "inkscape",
			class = { "inkscape", "org.inkscape.Inkscape" },
		}),
		description = "Inkscape",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "3",
		on_press = spawn_or_cycle({
			command = "Zalo",
		}),
		description = "Zalo",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "5",
		on_press = spawn_or_cycle({
			command = "libreoffice --norestore",
			matcher = function(c)
				local sw = gears.string.startswith
				local c1 = sw(c.class, "libreoffice")
				local c2 = sw(c.class, "startscenter")
				return c1 or c2
			end,
		}),
		description = "Libreoffice",
		group = "Application",
	}),
	awful.key({
		modifiers = { modkey, "Shift" },
		key = "5",
		on_press = spawn_or_cycle({
			command = "OnlyOffice",
			matcher = "ONLYOFFICE",
		}),
		description = "OnlyOffice",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "6",
		on_press = spawn_or_cycle({
			command = "keepassxc",
			class = "org.keepassxc.KeePassXC",
		}),
		description = "Keepassxc",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "7",
		on_press = spawn_or_cycle({
			command = "lyx",
			matcher = { "lyx", "texstudio" },
		}),
		description = "LyX/TeX editor",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "8",
		on_press = spawn_or_cycle({
			command = "qpdfview",
			class = "qpdfview.local.qpdfview",
		}),
		description = "LyX/TeX editor",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey, "Shift" },
		key = "8",
		on_press = spawn_or_cycle({
			command = "xournalpp",
			class = "com.github.xournalpp.xournalpp",
		}),
		description = "PDF viewer/annotator",
		group = "Application",
	}),

	awful.key({
		modifiers = { modkey },
		key = "9",
		on_press = spawn_or_cycle({
			command = "nemo",
			class = "nemo",
		}),
		description = "Nemo file manager",
		group = "Application",
	}),

	-- Switch client
	awful.key({
		modifiers = { modkey },
		key = "t",
		on_press = function()
			require("lib.split").show()
		end,
		description = "Select a client and split screen",
	}),
	awful.key({
		modifiers = { modkey },
		key = "j",
		on_press = function()
			local ts = require("ndgnuh.task_switcher")
			ts.select_next()
		end,
	}),
	awful.key({
		modifiers = { modkey },
		key = "k",
		on_press = function()
			local ts = require("ndgnuh.task_switcher")
			ts.select_previous()
		end,
	}),
	awful.key({
		modifiers = { modkey },
		key = "l",
		on_press = awful.tag.viewnext,
		description = "View next tag/client",
		group = "SomeWM",
	}),
	awful.key({
		modifiers = { modkey },
		key = "h",
		on_press = awful.tag.viewprev,
		description = "View previous tag/client",
		group = "SomeWM",
	}),

	-- Run prompt
	awful.key({
		modifiers = { modkey },
		key = "r",
		on_press = function()
			runprompt:run()
		end,
		description = "Run command prompt",
		group = "somewm",
	}),

	-- Session related
	awful.key({
		modifiers = { modkey, "Control" },
		key = "r",
		on_press = awesome.restart,
		description = "reload somewm",
		group = "somewm",
	}),

	awful.key({ modkey, "Shift" }, "q", function()
		awful.spawn.easy_async_with_shell("wlogout")
	end, { description = "quit awesome", group = "awesome" }),

	-- Toggle wibar
	awful.key({
		modifiers = { modkey },
		key = "b",
		on_press = function()
			awesome.emit_signal("wibar:toggle")
		end,
		description = "quit awesome",
		group = "awesome",
	}),

	-- Main menu
	awful.key({
		modifiers = { modkey },
		key = "w",
		on_press = function()
			awesome.emit_signal("show-main-menu")
		end,
		description = "show main menu",
		group = "awesome",
	}),

	-- Show launcher
	awful.key({
		modifiers = { modkey },
		key = "p",
		on_press = function()
			awesome.emit_signal("show-launcher")
		end,
		description = "show launcher",
		group = "awesome",
	}),

	-- Media: display
	awful.key({
		modifiers = {},
		key = "XF86Display",
		on_press = function()
			awful.spawn.raise_or_spawn("wdisplays")
		end,
		description = "Open screen configuration",
		group = "Media",
	}),

	-- audio (requires wpctl from wireplumber)
	awful.key({
		modifiers = {},
		key = "XF86AudioRaiseVolume",
		on_press = function()
			awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
		end,
		description = "raise volume",
		group = "Audio",
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioLowerVolume",
		on_press = function()
			awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
		end,
		description = "lower volume",
		group = "Audio",
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioMute",
		on_press = function()
			awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
		end,
		description = "mute output",
		group = "Audio",
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioMicMute",
		on_press = function()
			awful.spawn("wpctl set-mute @DEFAULT_SOURCE@ toggle")
		end,
		description = "mute microphone",
		group = "Audio",
	}),

	-- brightness (requires brightnessctl)
	awful.key({
		modifiers = {},
		key = "XF86MonBrightnessUp",
		on_press = function()
			awful.spawn("brightnessctl set 5%+")
		end,
		description = "raise brightness",
		group = "Brightness",
	}),
	awful.key({
		modifiers = {},
		key = "XF86MonBrightnessDown",
		on_press = function()
			awful.spawn("brightnessctl set 5%-")
		end,
		description = "lower brightness",
		group = "Brightness",
	}),

	-- Toggle viewing current tag
	awful.key({
		modifiers = { modkey },
		key = "0",
		on_press = function()
			local s = awful.screen.focused()
			local t = s.selected_tag
			if t then
				current_tag = t
				awful.tag.viewnone()
			elseif current_tag then
				awful.tag.viewtoggle(current_tag)
			end
		end,
	}),

	-- Cycle marked clients
	awful.key({
		modifiers = { modkey },
		key = "m",
		on_press = function()
			manual_focus_group.focus()
		end,
	}),

	-- Modal key binding?
	awful.key({
		modifiers = { modkey },
		key = "Space",
		on_press = function()
			ic("Not implemented")
		end,
	}),
}

-- root._keys({})
awful.keyboard.append_global_keybindings(keys)

awful.keyboard.append_client_keybindings({
	awful.key({
		modifiers = { modkey },
		key = "c",
		on_press = client_menu,
		description = "Show client menu",
		group = "Client",
	}),

	-- Move to volatile tag and normalize
	awful.key({
		modifiers = { modkey, "Shift" },
		key = "v",
		on_press = function(c)
			client_api.move_to_volatile(c, awful.layout.suit.max)
			client_api.normalize(c)
		end,
	}),

	awful.key({
		modifiers = { modkey },
		key = "z",
		on_press = function(c)
			local menu = require("ndgnuh.client_menu")
			menu.show_bamboo_menu()
		end,
	}),

	-- Minimize client
	awful.key({
		modifiers = { modkey },
		key = "n",
		on_press = function(c)
			c.minimized = true
		end,
		description = "minimize",
		group = "client",
	}),

	-- Mark and unmark clients
	awful.key({
		modifiers = { modkey, "Shift" },
		key = "m",
		on_press = function(c)
			manual_focus_group.toggle_mark(c)
		end,
	}),
	awful.key({
		modifiers = { modkey, "Control" },
		key = "m",
		on_press = function(c)
			manual_focus_group.unmark(c)
		end,
	}),
})
