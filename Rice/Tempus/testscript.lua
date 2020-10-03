#!env lua5.3

local helper = require("c_helper")
local map, mapi = helper.map, helper.mapinplace
local range = helper.range

for k, v in pairs(helper) do
	print(k, ": ", v)
	rawset(_G, k, v)
end

t1 = range(3)
t2 = range(2, 4)
t3 = range(0.1, 0.2, 1)
-- t4, err = pcall(range, 0.1, nil, 1)

local add = function(x, y)
	return x + y
end

local double = function(x) return x * 2 end

local dump = function(t)
	print("---------")
	for i = 1,#t do
		print(string.format("%s: %s", i, t[i]))
	end
end

dump(mapinplace(double, range(100)))
