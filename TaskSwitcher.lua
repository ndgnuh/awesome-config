-- @module TaskSwitcher
-- @author ndgnuh
-- @description Create a Alt - Tab like behavior task switcher

local TaskSwitcher = {}

local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
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
			wibox.widget.textbox("hello"),
			-- forced_height = 400
		}
	}

	box.focus_idx = 1

	-- timer for the wibox to go invisible
	box.timer = gtimer{
		timeout = timeout,
		callback = function() box.visible = false end
	}

	-- when triggered, by button press or key binding
	box:connect_signal("triggered", function(self)
		-- get all clients
		allClients = client.get()
		-- rerender the widget
		if self.visible then
			self.focus_idx = (self.focus_idx % #allClients) + 1
		else
			self.focus_idx = 1
		end
		renderTaskSwitcher(self, allClients, self.focus_idx, not self.visible)
		self.visible = true
		-- reset the timer
		self.timer:again()
		-- @deprecated {{{
		-- if self.visible then
		-- 	self.focus_idx = self.focus_idx + 1
		-- else
		-- 	self.visible = true
		-- 	-- find the focused client
		-- 	-- replace the box focus idx
		-- 	for i, c in ipairs(allClients) do
		-- 		if client.focus == c then
		-- 			self.focus_idx = i
		-- 			break
		-- 		end
		-- 	end
		-- end
		-- @deprecated }}}
	end)

	-- dismiss on click
	box:buttons(awful.button({}, 3, function(self)
		self.visible = false
	end))

	box.trigger = function(self) self:emit_signal("triggered") end

	-- return the wibox
	return box
end

return new
