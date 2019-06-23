local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

custom_exit = "yeslol"
local triggerkeys = {}

local function mkbtn(str, onclick)
	local btn = wibox.widget({widget = wibox.widget.textbox, align = "center", valign = "center", markup = str})
	local wrap = wibox.container.background(btn, nil)
	wrap:connect_signal("mouse::enter"	, function() wrap.bg = "#ffffff13" end)
	wrap:connect_signal("mouse::leave"	, function() wrap.bg = nil end)
	if type(onclick) == "string" then
		function wrap.run()
			awful.spawn.easy_async_with_shell(onclick, function(o) naughty.notify({text = o}) end) 
		end
	else
		wrap.run = onclick
	end
	return wrap
end

local s = awful.screen.focused()
	s.goodbye = wibox({
		ontop =true,
		visible = false,
		width = s.geometry.width,
		height = s.geometry.height,
		x = s.geometry.x,
		y = 0,
	})

	s.goodbye.buttons = {}
	s.goodbye.buttons[0] = mkbtn("<u>s</u>hutdown"	, "systemctl poweroff")
	s.goodbye.buttons[1] = mkbtn("<u>r</u>eboot"	, "systemctl reboot")
	s.goodbye.buttons[2] = mkbtn("<u>l</u>ogout"	, awesome.quit)
	s.goodbye.buttons[3] = mkbtn("<u>h</u>ibernate"	, "systemctl hibernate")
	s.goodbye.buttons[4] = mkbtn("sus<u>p</u>end"	, "systemctl suspend")
	s.goodbye.buttons[5] = mkbtn("<u>c</u>ancel"	, function() s.goodbye.visbile = false end)

	s.goodbye:setup({
		layout =wibox.layout.flex.horizontal,
		s.goodbye.buttons[0],
		s.goodbye.buttons[1],
		s.goodbye.buttons[2],
		s.goodbye.buttons[3],
		s.goodbye.buttons[4],
		s.goodbye.buttons[5],
	})

	s.keygrab = awful.keygrabber({
		keybindings = { 
			{{}, "s", function() s.goodbye.buttons[0]:emit_signal("widget::active") end},
			{{}, "r", function() s.goodbye.buttons[1]:emit_signal("widget::active") end},
			{{}, "l", function() s.goodbye.buttons[2]:emit_signal("widget::active") end},
			{{}, "h", function() s.goodbye.buttons[3]:emit_signal("widget::active") end},
			{{}, "p", function() s.goodbye.buttons[4]:emit_signal("widget::active") end},
			{{}, "c", function() s.goodbye.buttons[5]:emit_signal("widget::actice") end},
		},
		stop_key = "c",
		stop_callback = function() s.goodbye.visible = false end
	})

	local triggerkeys = gears.table.join(triggerkeys, awful.key({"Mod1", "Shift" }, "e", function()
		s.goodbye.visible = true
		s.keygrab:start()
	end))
	
	for i=0,#s.goodbye.buttons do
		s.goodbye.buttons[i]:connect_signal("widget::active", function()
			s.goodbye.visible = false
			s.keygrab:stop()
			s.goodbye.buttons[i].run()
		end)
	end

root.keys(gears.table.join(triggerkeys, root.keys()))
