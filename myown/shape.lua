local shape = {}
local math = require("math")
local gears = require("gears")
local min = math.min
local max = math.max
local sin = math.sin
local cos = math.cos
local tan = math.tan
local exp = math.exp
local abs = math.abs
local pow = math.pow or function(a, b) return a^b end
local pi = math.pi
local sign = function(x) return x > 0 and 1 or -1 end

function shape.crystal(cr, w, h)
	local s = min(w, h)
	local b = 1 * s * tan(pi/180*16.18)
	cr:move_to(0, s)
	cr:line_to(b, s)
	cr:line_to(s, b)
	cr:line_to(s, 0)
	cr:line_to(s - b, 0)
	cr:line_to(0, s - b)
	cr:close_path()
end

--- shape.squircle(cr, w, h, rate, delta)
-- @param cr: cairo context
-- @param w: shape width
-- @param h: shape height
-- @param rate: the rate of which the squircle is "squared". (default: 2)
-- @param delta: the angle value step (default 0.05)
function shape.squircle(cr, w, h, rate, delta)
	-- rate ~ 2 can be used by icon
	-- this shape doesn't really fit clients
	-- but you can still use with rate ~ 32
	rate = rate or 2
	-- smaller the delta the smoother the shape
	-- but probably more laggy
	delta = delta or 0.05
	local a = w / 2
	local b = h / 2
	local phi = 0

	-- move to origin
	cr:save()
	cr:translate(a, b)

	-- draw with polar cord
	while phi < 2 * pi do
		local cosphi = cos(phi)
		local sinphi = sin(phi)
		local x = a * pow(abs(cosphi), 1 / rate) * sign(cosphi)
		local y = b * pow(abs(sinphi), 1 / rate) * sign(sinphi)
		-- so weird, y axis is inverted
		cr:line_to(x, -y)
		phi = phi + delta
	end
	cr:close_path()

	-- restore cairo context
	cr:restore()
end

shape.star = function(cr, w, h, n)
	-- use the minimum as size
	local s = math.min(w, h) / 2
	n = n or 5 -- anything from 2 or above will work
	local a = 2 * math.pi / n
	-- place the star at the center
	cr:translate(w/2, h/2)
	cr:rotate(-math.pi/2)
	for i = 0,(n - 1) do
		cr:line_to(s   * math.cos(i         * a), s   * math.sin(i         * a))
		cr:line_to(s/2 * math.cos((i + 0.5) * a), s/2 * math.sin((i + 0.5) * a))
	end
	cr:close_path()
end

shape.mt = {
	__index = function(self, i)
		return rawget(self, i) or gears.shape[i]
	end
}

return setmetatable(shape, shape.mt)
