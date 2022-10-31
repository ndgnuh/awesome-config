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
	local callback = args.callback or default_set_geometry
	local done_callback = args.done_callback or function(...) end
	local animation = args.animation or {}
	local target = 1
	local run_now = args.run_now or true

	animation.duration = animation.duration or 0.2
	animation.subscribed = function(t)
		local g = interpolate(args.init, args.target, t)
		callback(t, drawable, g, args.timed)
		if t == target then
			done_callback(t, drawable, g, args.timed)
		end
	end

	local timed = rubato.timed(animation)
	if run_now then
		timed.target = 1
	end

	args.timed = timed
	return args
end

local function create_animation(args)
	--
end

local function animation(args)
	local obj = {}
	obj.init = args.init
	obj.target = args.target
	obj.timed = rubato.timed({
		duration = args.duration or 0.13,
		override_dt = args.override_dt or false,
		subscribed = function(t)
			local g = interpolate(args.init, args.target, t)
			callback(obj, g, t)
		end,
	})
	return obj
end

local module = {
	animate = animate,
	animation = animation,
}

module = setmetatable(module, {
	__call = function(self, ...)
		self.animate(...)
	end,
})

return module
