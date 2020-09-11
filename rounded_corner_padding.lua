local awful = re'awful'
local beautiful = re'beautiful'
local shape = re'gears.shape'
local wibox = re'wibox'
local pi = math.pi

local cornershapes = {}
local radius = beautiful.border_radius or 10

cornershapes[1] = function(cr, w, h)
	cr:move_to(0, radius)
	cr:arc(radius, radius, radius, pi, pi * 1.5)
	cr:line_to(0, 0)
	cr:line_to(0, radius)
	cr:close_path()
end

for i = 2, 4 do
	cornershapes[i] = shape.transform(cornershapes[1]):
		translate(radius/2, radius/2):
		rotate(pi * 0.5 * (i - 1)):
		translate(-radius/2, -radius/2)
end

return function(s)
	local w_area = s.workarea
	local positions = {
		{w_area.x, w_area.y}, --[[ top left ]]
		{w_area.x + w_area.width - radius, w_area.y}, --[[ top right ]]
		{w_area.x + w_area.width - radius, w_area.y + w_area.height - radius}, --[[ bottom right ]]
		{w_area.x, w_area.y + w_area.height - radius}, --[[ bottom left ]]
	}
	-- screen corners
	s.corners = {}
	-- top left
	for i = 1, 4 do
		s.corners[i] = wibox {
			shape = cornershapes[i],
			screen = s,
			x = positions[i][1],
			y = positions[i][2],
			width = 10,
			height = 10,
			bg = beautiful.wibar_bg,
			visible = true,
		}
	end
end
