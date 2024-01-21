-- usage:
-- rrequire("module", ...)
return function(name, ...)
	local relative = (...):match("(.-)[^%.]+$") 
	return require(relative .. name)
end
