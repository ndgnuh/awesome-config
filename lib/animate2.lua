local rubato = require("lib.rubato")
local throttle = require("lib.throttle")

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

local function default_set_geometry(t, w, g)
	w:geometry(g)
end

local function animate(args)
	local drawable = args.widget
	local g1 = args.init
	local g2 = args.target
	local callback = args.callback or default_set_geometry
	local done_callback = args.done_callback or function(...) end
	local animation = args.animation or {}
	local target = 1

	animation.intro = animation.intro or 0.1
	animation.duration = animation.duration or 0.2
	animation.subscribed = function(t)
		local g = interpolate(g1, g2, t)
		callback(t, drawable, g)
		if t == target then
			done_callback(t, drawable, g)
		end
	end

	local timed = rubato.timed(animation)
	timed.target = target
end

return animate
