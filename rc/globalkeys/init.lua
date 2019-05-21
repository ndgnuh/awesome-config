local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local mod = "Mod1"
local terminal = "sakura"

require("rc.globalkeys.media")

local globalkeys = gears.table.join(
	awful.key({ mod, }, "s", function() awful.screen.focus_relative(1) end),
	awful.key({ mod, }, "Left", 	awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
	awful.key({ mod, }, "Right", 	awful.tag.viewnext,
		{description = "view next", group = "tag"}),
	awful.key({ mod, }, "Escape", 	awful.tag.history.restore,
		{description = "go back", group = "tag"}),
	awful.key({ mod, }, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus next by index", group = "client"}),
	awful.key({ mod, }, "k",
		function ()
				awful.client.focus.byidx(-1)
		end,
		{description = "focus previous by index", group = "client"}),
	awful.key({ mod, }, "w", 		function () mymainmenu:show() end,
		{description = "show main menu", group = "awesome"}),

-- Layout manipulation
	awful.key({ mod, "Shift" }, "j", 		function () 	awful.client.swap.byidx( 1) end,
		{description = "swap with next client by index", group = "client"}),
	awful.key({ mod, "Shift" }, "k", 		function () 	awful.client.swap.byidx( -1) end,
		{description = "swap with previous client by index", group = "client"}),
	awful.key({ mod, "Control" }, "j", 		function () 	awful.screen.focus_relative( 1) end,
		{description = "focus the next screen", group = "screen"}),
	awful.key({ mod, "Control" }, "k", 		function () 	awful.screen.focus_relative(-1) end,
		{description = "focus the previous screen", group = "screen"}),
	awful.key({ mod, }, "u", 	awful.client.urgent.jumpto,
		{description = "jump to urgent client", group = "client"}),
	awful.key({ mod, }, "Tab",
				function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),

-- Standard program
	awful.key({ mod, }, "Return", 		function () 	awful.spawn("sakura") end,
		{description = "open a config.term", group = "launcher"}),
	awful.key({ mod, "Shift" }, "r", awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	-- awful.key({ mod, "Shift" }, "e", awesome.quit,
	-- 	{description = "quit awesome", group = "awesome"}),

	awful.key({ mod, }, "l", 		function () 	awful.tag.incmwfact( 0.05) end,
		{description = "increase master width factor", group = "layout"}),
	awful.key({ mod, }, "h", 		function () 	awful.tag.incmwfact(-0.05) end,
		{description = "decrease master width factor", group = "layout"}),
	awful.key({ mod, "Shift" }, "h", 		function () 	awful.tag.incnmaster( 1, nil, true) end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({ mod, "Shift" }, "l", 		function () 	awful.tag.incnmaster(-1, nil, true) end,
		{description = "decrease the number of master clients", group = "layout"}),
	awful.key({ mod, "Control" }, "h", 		function () 	awful.tag.incncol( 1, nil, true) end,
		{description = "increase the number of columns", group = "layout"}),
	awful.key({ mod, "Control" }, "l", 		function () 	awful.tag.incncol(-1, nil, true) end,
		{description = "decrease the number of columns", group = "layout"}),
	awful.key({ mod, }, "space", 		function () 	awful.layout.inc( 1) end,
		{description = "select next", group = "layout"}),
	awful.key({ mod, "Shift" }, "space", 		function () 	awful.layout.inc(-1) end,
		{description = "select previous", group = "layout"}),

	awful.key({ mod, "Control" }, "n",
		function ()
			local c = awful.client.restore()
			if c then
				c:emit_signal(
				"request::activate", "key.unminimize", {raise = true}
			)
			end
		end,
		{description = "restore minimized", group = "client"}),

	awful.key({ mod }, "d", function () awful.spawn("dmenu_run -b") end,
		{description = "run prompt", group = "launcher"}),

	awful.key({ mod }, "x",
		function ()
			awful.prompt.run {
			prompt = "Run Lua code: ",
			textbox = 	awful.screen.focused().mypromptbox.widget,
			exe_callback = 	awful.util.eval,
			history_path = 	awful.util.get_cache_dir() .. "/history_eval"
			}
		end,
		{description = "lua execute prompt", group = "awesome"}),
-- Menubar
	awful.key({ mod }, "p", 		function() menubar.show() end,
		{description = "show the menubar", group = "launcher"})
)

for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ mod }, "#" .. i + 9,
				function ()
			local screen = 	awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end,
		{description = "view tag #"..i, group = "tag"}),

		-- Toggle tag display.
		awful.key({ mod, "Control" }, "#" .. i + 9,
				function ()
			local screen = 	awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
					awful.tag.viewtoggle(tag)
			end
		end,
		{description = "toggle tag #" .. i, group = "tag"}),

		-- Move client to tag.
		awful.key({ mod, "Shift" }, "#" .. i + 9,
				function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
		{description = "move focused client to tag #"..i, group = "tag"}),

		-- Toggle tag on focused client.
			awful.key({ mod, "Control", "Shift" }, "#" .. i + 9,
				function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
		{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

root.keys(gears.table.join(
	globalkeys,
	root.keys()
))
