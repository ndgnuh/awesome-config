---A state management library inspired by `riverpod.dart`.
---Just like riverpod, `overdrip` is just an anagram of `provider`
---The name is also kind of whimsical, therefore only (Awe)SomeWM could probably have a use for it.
local gears = require("gears")
local Ref = require.rel("ref")
local scheduler = require.rel("scheduler").new()

---@class overdrip.Provider
---@field state any
---@field builder fun(ref: overdrip.Ref): any
---@field subscribers table<function, function>
---@field dependencies table<overdrip.Provider, function>
---@field dirty boolean
local Provider = {
	-- current state of provider, should not be read directly
	state = nil,
	-- build function, to be set
	builder = function(_) end,
	-- List of the function that depends on the provider
	dependents = setmetatable({}, { __mode = "v" }),
	-- List of the function that this provider depends on
	dependencies = setmetatable({}, { __mode = "v" }),
	-- Should we rebuild
	dirty = true,
}

function Provider:set(state)
	if state ~= self.state then
		self.state = state
		self:notify_listeners()
	end
	self.dirty = false
end

function Provider:get()
	return self:flush()
end

--- Recompute and/or return the state of the provider
function Provider:flush()
	if not self.dirty then
		return self.state
	end

	-- clear dependencies
	for _, provider in ipairs(self.dependencies) do
		-- remove this one from the parent dependents,
		-- the builder will add it again if it still watches the parent
		for i = #provider.dependents, 1, -1 do
			if provider.dependents[i] == self then
				table.remove(provider.dependents, i)
			end
		end
	end
	self.dependencies = setmetatable({}, { __mode = "v" })

	-- The magic happens here
	local ref = Ref.new(self)
	self:set(self.builder(ref))
	return self.state
end

-- problem:
-- provider1 :base
-- provider2 : watch provider1
-- provider3 : watch provider1 and provider2
-- when provider1 changes, the provider2 and provider3 is notified
-- when provider2 is notified, then provider3 is notified again
-- how to make sure provider3 is only recomputed once?
function Provider:notify_listeners()
	for _, dependent in ipairs(self.dependents) do
		dependent:invalidate_self()
	end
end
function Provider:add_listener(dependent)
	table.insert(self.dependents, dependent)
	table.insert(dependent.dependencies, self)
end

function Provider:invalidate_self()
	if self.dirty then
		return
	end
	self.dirty = true
	scheduler:schedule_to_refresh(self)
end

function Provider.new(builder)
	local provider = gears.table.clone(Provider, true)

	if type(builder) == "function" then
		provider.builder = builder
	else
		-- Constant initialized provider
		provider.dirty = false
		provider.state = builder
		provider.builder = function()
			return builder
		end
	end

	return provider
end

setmetatable(Provider, {
	__call = function(_, builder)
		return Provider.new(builder)
	end,
})

return Provider
