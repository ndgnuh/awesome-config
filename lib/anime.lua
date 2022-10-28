local rubato = require("lib.rubato")

local function interpolate(x1, x2, t)
	return x1 * (1 - t) + x2 * t
end

local function default_set_geometry(w, g)
	w:geometry(g)
end

local function animate(args)
	local drawable = args.widget
	local g1 = drawable:geometry()
	local g2 = args.geometry

	geometry_setter = geometry_setter or default_set_geometry

	args = args or {}
	args.intro = args.intro or 0.1
	args.duration = args.duration or 0.2
	args.override_dt = args.override_dt or false
	args.subscribed = function(t)
		local g = {}
		for k, v in pairs(g1) do
			g[k] = interpolate(g1[k], g2[k], t)
		end
		geometry_setter(drawable, g)
	end

	local timed = rubato.timed(args)
	timed.target = 1
end

return { animate = ani }
