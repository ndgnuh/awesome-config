local awful = re'awful'
local beautiful = re'beautiful'
local shape = re'gears.shape'
local wibox = re'wibox'
local pi = math.pi

local radius = beautiful.border_radius or 10

local cornershape = function(cr, w, h)
	cr:move_to(0, radius)
	cr:arc(radius, radius, radius, pi, pi * 1.5)
	cr:line_to(0, 0)
	cr:line_to(0, radius)
	cr:close_path()
end

local aux = function(i)
	return shape.transform(cornershape):
		translate(radius/2, radius/2):
		rotate(pi * 0.5 * (i - 1)):
		translate(-radius/2, -radius/2)
end

local cornershapes = mapinplace(aux, range(1, 4))

return function(s)
	local w_area = s.workarea -- use workarea to count the wibar padding
	local positions = {
		x = {
			w_area.x,
			w_area.x + w_area.width - radius,
			w_area.x + w_area.width - radius,
			w_area.x,
		},
		y = {
			w_area.y,
			w_area.y,
			w_area.y + w_area.height - radius,
			w_area.y + w_area.height - radius,
		},
	}
	-- screen corners
	s.corners = {}
	-- setup wiboxes
	local aux = {
		shape = cornershapes[1],
		screen = s,
		x = 0,
		y = 0,
		width = radius,
		height = radius,
		bg = beautiful.wibar_bg,
		visible = true,
	}
	for i = 1, 4 do
		aux.shape = cornershapes[i]
		aux.x = positions.x[i]
		aux.y = positions.y[i]
		s.corners[i] = wibox(aux)
	end
end