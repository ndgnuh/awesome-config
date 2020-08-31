-- @module TaskSwitcher
-- @author ndgnuh
-- @description Create a Alt - Tab like behavior task switcher

local TaskSwitcher = {}

local awful = require("awful")
local common = require("awful.widget.common")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gtable = require("gears.table")
local client = client
local max = math.max
local min = math.min
local mod = math.mod

-- @function renderTask(box, client index)
-- render the task item in tasklist
local renderTask = function(box, idx, args)
	local c = box.client[idx]
	local isFocus = idx == box.focus_idx

	local selectedBackground = args.selectedBackground
		or beautiful.taskSwitcherSelectedBackground
		or beautiful.taskSwitcherBackground
		or beautiful.bg_focus
	local normalBackground = args.normalBackground
		or beautiful.taskSwitcherNormalBackground
		or beautiful.taskSwitcherBackground
		or beautiful.bg_normal
	local normalForeground = args.normalForeground
		or beautiful.taskSwitcherNormalBackground
		or beautiful.taskSwitcherForeground
		or beautiful.fg_normal
	local selectedForeground = args.selectedForeground
		or beautiful.taskSwitcherSelectedBackground
		or beautiful.taskSwitcherForeground
		or beautiful.fg_focus
	local normalFont = args.normalFont
		or beautiful.taskSwitcherNormalFont
		or beautiful.taskSwitcherFont
		or beautiful.font
	local selectedFont = args.selectedFont
		or beautiful.taskSwitcherSelectedFont
		or beautiful.taskSwitcherFont
		or beautiful.font

	return wibox.widget{
		widget = wibox.container.background,
		bg = isFocus and selectedBackground or normalBackground,
		forced_height = 48,
		forced_width = 1024,
		{
			layout = wibox.layout.fixed.horizontal,
			{
				widget = wibox.widget.textbox,
				markup = (isFocus and " > " or ""),
				align = 'center',
				forced_width = 30,
			},
			{
				widget = awful.widget.clienticon,
				client = c,
			},
			{
				widget = wibox.widget.textbox,
				markup = c.name,
			},
		},
	}
end

--- Rerender the task switcher
-- @TODO:
-- [x] nice render instead of textbox
-- [x] cycle render
local renderTaskSwitcher = function(box, allClients, focus_idx, isFromStart, args)
	box.widget:reset()
	-- render from start to number of clients
	for i = 1,#allClients do
		box.widget:add(renderTask(box, i, args))
	end
	-- dump(focus_idx)
end

-- use widget.common
local renderTaskSwitcher2 = function(box, widget_template)
	common.list_update(box.widget, _, _, _, box.client, {
			widget_template = widget_template
		})
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
local defaultArgs = {}
local new = function(args)
	args = args or defaultArgs
	timeout = args.timeout or 5

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
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible, args)
	end)

	-- focus_idx forward
	box:connect_signal("forward", function(self)
		self.focus_idx = (self.focus_idx % #self.client) + 1
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible, args)
	end)

	-- focus_idx backward
	box:connect_signal("backward", function(self)
		self.focus_idx = (self.focus_idx - 2) % #self.client + 1
		renderTaskSwitcher(self, self.client, self.focus_idx, not self.visible, args)
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
