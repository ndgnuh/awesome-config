local wibox = require("wibox")

local revealer = function(parent, child, direction)
	-- adapt parameters
	if direction == "v" then
		direction = "vertical"
	else
		direction = "horizontal"
	end

	local w = wibox.widget{
		layout = wibox.layout.fixed[direction],
		child
	}

	return w
end
