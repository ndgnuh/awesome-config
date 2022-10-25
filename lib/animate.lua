local rubato = require("lib.rubato")

local function interpolate(x1, x2, t)
	if type(x2) == "table" then
		local result = {}
		for k, v in pairs(x2) do
			rawset(result, k, interpolate(x1[k], x2[k], t))
		end
		return result
	else
		return x1 * (1 - t) + x2 * t
	end
end

local function default_set_geometry(w, g)
	w:geometry(g)
end

local function animate(args)
	local drawable = args.widget
	local g1 = drawable:geometry()
	local g2 = args.geometry or {}
	local set_geometry = args.geometry_setter or default_set_geometry

	local animation = args.animation or {}
	animation.intro = animation.intro or 0.1
	animation.duration = animation.duration or 0.2
	animation.override_dt = animation.override_dt or false
	animation.subscribed = function(t)
		local g = interpolate(g1, g2, t)
		set_geometry(drawable, g)
	end

	local timed = rubato.timed(animation)
	timed.target = 1
end

return animate
