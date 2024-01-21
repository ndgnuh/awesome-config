-- Idea: 
-- use beautiful.get_font_height on font size to get the constraint of the icon size
-- use beautiful.place to place the image in the middle
local awful = require("awful")
local beautiful = require("beautiful")
local base = require("wibox.widget.base")
local wibox = require("wibox")
local gtable = require("gears.table")

local iconbox = {mt = {}}

function iconbox:set_children(children)
	local fs = beautiful.em
	for _, child in ipairs(children) do
		child.forced_width = fs
		child.forced_height = fs
	end
	wibox.container.place.set_children(self, children)
end

function iconbox.mt.__call(image)
	local ret = wibox.container.place()
	-- gtable.crush(ret, iconbox, true)
	return ret
end

return setmetatable(iconbox, iconbox.mt)
