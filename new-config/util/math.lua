add = function(x, y) return x + y end
sub = function(x, y) return x - y end
mul = function(x, y) return x * y end
div = function(x, y) return x / y end
mod = function(x, y) return x % y end
pow = math.pow or function(x, y) return x^y end
sum = function(...)
	local s = 0
	for i = 1, select("#", ...) do
		s = s + select(i, ...)
	end
end
