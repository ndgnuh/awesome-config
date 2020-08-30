-- @module TaskSwitcher
-- @author ndgnuh
-- @description Create a Alt - Tab like behavior task switcher

local TaskSwitcher = {}

local awful = require("awful")
local gtimer = require("gears.timer")
local gtable = require("gears.table")
local client = client

--- Rerender the task switcher
local renderTaskSwitcher = function(box, allClients, isFromStart)
	-- @TODO:
	-- If isFromStart then set focus_idx at 1
	-- else set focus_idx at next
end

--- Create the TaskSwitcher box
-- @TODO:
-- [x] get all clients
-- [x] get focused client
-- [ ] move focus idx according to press and rerender
-- [x] dismiss after timeout
-- [x] reset timeout per keypress
-- [ ] theme-able via beautiful
-- [ ] modularize the code
local new = function(args)
	timeout = args.timeout or 5

	local box = awful.popup{
		visible = false, ontop = true,
		placement = awful.placement.center,
		widget = wibox.widget{
			widget = wibox.layout.fixed.vertical,
		}
	}

	box.focus_idx = 1

	-- timer for the wibox to go invisible
	box.timer = gears.timer{
		timeout = timeout,
		callback = function() box.visible = false end
	}

	-- when triggered, by button press or key binding
	box:connect_signal("triggered", function(self)
		allClients = client.get()
		-- if the box is already visible
		if self.visible then
			self.focus_idx = self.focus_idx + 1
		else
			self.visible = true
			-- find the focused client
			-- replace the box focus idx
			for i, c in ipairs(allClients) do
				if client.focus == c then
					self.focus_idx = i
					break
				end
			end
		end
		-- reset the timer
		self.timer:again()
	end)

	-- return the wibox
	return box
end

return new
