-- @module TaskSwitcher
-- @author ndgnuh
-- @description Create a Alt - Tab like behavior task switcher

local TaskSwitcher = {}

local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local client = client
local max = math.max
local min = math.min
local mod = math.mod

--- Rerender the task switcher
-- @TODO:
-- [ ] nice render instead of textbox
-- [ ] cycle render
local renderTaskSwitcher = function(box, allClients, focus_idx, isFromStart)
	box.widget:reset()
	-- render from start to number of clients
	for i = 1,#allClients do
		local text = allClients[i].name
		if i == focus_idx then
			text = "<i>" .. text .. "</i>"
		end
		box.widget:add(wibox.widget.textbox(text))
	end
	-- dump(focus_idx)
end

--- Create the TaskSwitcher box
-- @TODO:
-- [x] get all clients
-- [x] get focused client
-- [ ] focus to selected client after release the modkey
-- [ ] move focus idx according to press and rerender
-- [x] dismiss after timeout
-- [x] reset timeout per keypress
-- [ ] theme-able via beautiful
-- [ ] modularize the code
local new = function(args)
	timeout = args and args.timeout or 5

	local box = awful.popup{
		visible = false, ontop = true,
		placement = awful.placement.centered,
		widget = {
			widget = wibox.layout.fixed.vertical,
		}
	}

	-- grabber
	box.keygrabber = awful.keygrabber{
		keybindings = {
			{{modkey}, "j", function() box:emit_signal("forward") end},
			{{modkey}, "k", function() box:emit_signal("backward") end}
		},
		stop_key = modkey,
		stop_event = 'release',
		stop_callback = function()
			box.visible = false
			client.focus = box.client[box.focus_idx]
			if client.focus then
				client.focus:raise()
			end
		end,
		export_keybinding = true
	}
	box.keygrabber.started = false

	-- focus index of the task list
	box.focus_idx = 1

	-- when triggered, by button press or key binding
	box:connect_signal("triggered", function(self)
		-- set widget visible
		self.visible = true
		-- get all clients
		self.client = client.get()
		-- start key grabber
		self.keygrabber:start()
		-- rerender the widget
		for i, c in ipairs(self.client) do
			if client.focus == c then
				self.focus_idx = i
				break
			end
		end
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible)
	end)

	-- focus_idx forward
	box:connect_signal("forward", function(self)
		self.focus_idx = (self.focus_idx % #self.client) + 1
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible)
	end)

	-- focus_idx backward
	box:connect_signal("backward", function(self)
		self.focus_idx = (self.focus_idx - 2) % #self.client + 1
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible)
	end)


	-- dismiss on click
	box:buttons(awful.button({}, 3, function(self)
		self.visible = false
	end))

	-- trigger function, call with box:trigger()
	box.trigger = function(self) self:emit_signal("triggered") end

	-- return the wibox
	return box
end

return new
