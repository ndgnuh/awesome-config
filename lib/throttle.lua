local unpack = unpack or table.unpack
local gears = require("gears")
local function delayed(t, func, ...)
	local ref = {}
	local timer = gears.timer({
		single_shot = true,
		timeout = t,
		callback = function()
			func(table.unpack(ref.args))
		end,
	})
	return function(...)
		ref.args = { ... }
		timer:again()
	end
end

local function throttle(dt, func)
	local prev_exec_time = 0
	return function(...)
		local exec_time = os.clock()
		local delta = exec_time - prev_exec_time
		if prev_exec_time > 0 and delta < dt then
			return
		end
		prev_exec_time = exec_time
		return func(...)
	end
end

return { throttle = throttle, delayed = delayed }
