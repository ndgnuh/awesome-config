local function throttle(t, func, ...)
	local ref = {}
	local unpack = unpack or table.unpack
	local timer = gears.timer{
		single_shot = true,
		timeout = t,
		callback = function()
			func(table.unpack(ref.args))
		end
	}
	return function(...)
		ref.args = {...}
		timer:again()
	end
end
return throttle
