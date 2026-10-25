local gears = require("gears")

---@class overdrip.Ref
---@field element overdrip.Provider? Supposed to hold a provider
local Ref = {
	element = nil, -- Supposed to hold a provider
}

function Ref:read(dependency)
	return dependency:flush()
end

function Ref:watch(dependency)
	assert(self.element ~= dependency, "Cannot watch itself")
	dependency:add_listener(self.element)
	return dependency:flush()
end

function Ref:invalidate(provider)
	provider:invalidate_self()
end

function Ref:invalidate_self()
	self.element:invalidate_self()
end

---@param provider overdrip.Provider
function Ref.new(provider)
	---@type overdrip.Ref
	local ref = gears.table.clone(Ref)
	ref.element = provider

	return ref
end

return Ref
