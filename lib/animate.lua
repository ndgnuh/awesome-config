local rubato = require("lib.rubato")


local function interpolate(x1, x2, t)
	return x1 * (1 - t) + x2 * t
end

local function default_set_geometry(w, g)
	w:geometry(g)
end

local function easy_animate(drawable, g2, geometry_setter, args)
	geometry_setter = geometry_setter or default_set_geometry
	current = drawable:geometry()
	local g1 = drawable:geometry()

	args = args or {}
	args.intro = args.intro or 0.1
	args.duration = args.duration or 0.2
	args.override_dt = args.override_dt or false
	args.subscribed = function(t)
		local g = {
			x = interpolate(g1.x, g2.x, t),
			y = interpolate(g1.y, g2.y, t),
			width = interpolate(g1.width, g2.width, t),
			height = interpolate(g1.height, g2.height, t),
		}
		geometry_setter(drawable, g)
	end

	local timed = rubato.timed(args)
	timed.target = 1
end

local function easy_animation(drawable)
	-- anything with :geometry(), really
	local animation = {
		current = drawable:geometry()
	}

	animation.run = function(g2)
		animation.current = drawable:geometry()
		local g1 = animation.current
		local timed = rubato.timed{
			intro = 0.1,
			duration = 0.3,
			override_dt = true,
			subscribed = function(t)
				local g = {
					x = interpolate(g1.x, g2.x, t),
					y = interpolate(g1.y, g2.y, t),
					width = interpolate(g1.width, g2.width, t),
					height = interpolate(g1.height, g2.height, t),
				}
				drawable:geometry(g)
			end,
		}
		timed.target = 1
		-- dump(g1)
		animation.current = drawable:geometry()
	end

	return animation
end

return {easy_animation= easy_animation,easy_animate=easy_animate}


