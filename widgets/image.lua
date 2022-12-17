local gears = require("gears")
local gcolor = require("gears.color")
local widget = require("wibox.widget")
local container = require("wibox.container")

local dir = gears.filesystem.get_configuration_dir() .. "images/"

return function(name, color, margin)
	local image = dir .. name
	if color then
		image = gcolor.recolor_image(image, color)
	end
	local w = widget.imagebox(image)
	if margin then
		w = container.margin(w, margin, margin, margin, margin)
	end
	return w
end
