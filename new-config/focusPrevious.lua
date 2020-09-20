local gtable = re"gears.table"

local focusStack = {top = 1}
local sparseCount = 0
local sparseCountLimit = 10

local push = function(c)
	focusStack.top = focusStack.top + 1
	focusStack[focusStack.top] = c
end

local unsparse = function()
	focusStack = gtable.from_sparse(focusStack)
	focusStack.top = #focusStack
	return focusStack
end

client.connect_signal("focus", function(c)
	local pos = gtable.hasitem(focusStack, c)

	push(c)

	if pos then
		focusStack[pos] = nil
		if sparseCount > sparseCountLimit then
			sparseCount = 0
			unsparse(focusStack)
		else
			sparseCount = sparseCount + 1
		end
	end
end)

client.connect_signal("unmanage", function(c)
	local pos = gtable.hasitem(focusStack, c)
	if pos then
		focusStack[pos] = nil
		if sparseCount > sparseCountLimit then
			sparseCount = 0
			unsparse(focusStack)
		else
			sparseCount = sparseCount + 1
		end
	end
end)

local focusPrevious = function()
	local i = focusStack.top
	local c
	while (not c) and (i > 0) do
		i = i - 1
		c = focusStack[i]
	end
	pcall(c and c.emit_signal, c, "request::activate", nil, {raise = true})
end
return focusPrevious
