local mm = {}

local new = function(fs)
	local dtype
	local ret = { mt = {__mode = "v"}, vtable = {} }

	for types, f in pairs(fs) do
		local vnode, nargs = 0
		for types:g
		local iter = types:gmatch("[^_]+")
		for j = 1, #types - 1 do
			dtype = types[j] -- type of arg j
			-- if there's no table then create one
			if not ret.vtable[dtype] then
				ret.vtable[dtype] = {}
			end
			-- if j == 1, vnode is nil
			-- go the first depth
			-- if j > 1 then go to
			-- the next depth
			if j == 1 then
				vnode = ret.vtable[dtype]
			else
				vnode = vnode[dtype]
			end
		end
		-- at the last argument
		-- append the function
		vnode[types[#types]] = f
	end
	-- method "call"s
	ret.mt.__call = function(self, ...)
		local vnode = self.vtable
		local f
		local dtype
		for i = 1, select("#", ...) do
			dtype = select(i, ...)
			f = f[dtype]
			assert(f, "method not found")
		end
		return f(...)
	end
	-- return
	return setmetatable(ret, ret.mt)
end

return new
