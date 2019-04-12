local wibox = require("wibox")
local timer = require("gears.timer")
local gtable = require("gears.table")

local Popup = { mt = {} }

function Popup:trigger()
	self.wibox.visible = true
	self.wibox.ontop = true
	self.timer:again()
	self.callback()
end

function Popup:dismiss()
	self.wibox.visible = false
	self.wibox.ontop = false
end

function Popup.mt:__call(wibox, timeout, callback)
	callback = callback or function() end
	local ret = {
		wibox = wibox,
		timer = timer({
			timeout = timeout,
			callback = function() wibox.visible = false end
		}),
		callback = callback
	}
	gtable.crush(ret, Popup, true)
	return ret
end

return setmetatable(Popup, Popup.mt)
