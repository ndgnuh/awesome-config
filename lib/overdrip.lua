---A state management library inspired by `riverpod.dart`.
---Just like riverpod, `overdrip` is just an annagram of `provider`
---The name is also kind of whimsy, therefore only (Awe)SomeWM could probably have use it.
local gears = require("gears")
local wibox = require("wibox")
-- local ic = require("lib.icecream")

local m = {}
local Provider = {
	builder = nil,
	initialized = false,
	subscribers = {},
	dependencies = {},
}

function Provider:recompute()
	-- Clear previous dependencies between cycles
	for dep_provider, callback in pairs(self.dependencies) do
		dep_provider:disconnect_signal("property::state", callback)
	end
	self.dependencies = {}

	local update_function = function()
		self:recompute()
	end

	local ref = {
		watch = function(watchedProvider)
			assert(watchedProvider ~= self, "Cannot watch itself")
			self.dependencies[watchedProvider] = update_function
			return watchedProvider:get(update_function)
		end,
		invalidateSelf = function()
			self:recompute()
		end,
		invalidate = function(provider)
			provider:recompute()
		end,
		read = function(p)
			return p:get()
		end,
	}

	local new_state = self.builder(ref)
	if self.state ~= new_state or not self.initialized then
		self.state = new_state
		rawset(self, "initialized", true)
	end
	return self.state
end

function Provider:notify_all()
	-- Subscribers usually re-subscribe (via get) while being notified, and
	-- emit_signal iterates its callbacks with pairs(), so adding keys mid-emit
	-- breaks `next`. Queue new subscriptions and attach them afterwards.
	rawset(self, "_notifying", true)
	local ok, err = xpcall(self.emit_signal, debug.traceback, self, "property::state", self.state)
	rawset(self, "_notifying", false)

	local pending = rawget(self, "_pending")
	if pending then
		rawset(self, "_pending", nil)
		for callback in pairs(pending) do
			self:connect_signal("property::state", callback)
		end
	end

	if not ok then
		error(err, 0)
	end
end

function Provider:get(callback)
	if not self.initialized then
		self:recompute()
	end

	-- Attach subscriber if applicable (connect_signal is idempotent)
	if callback then
		if rawget(self, "_notifying") then
			local pending = rawget(self, "_pending") or {}
			pending[callback] = true
			rawset(self, "_pending", pending)
		else
			self:connect_signal("property::state", callback)
		end
	end

	return self.state
end

Provider = setmetatable(Provider, {
	__calll = Provider.new,
})

function m.provider(builder)
	local class = gears.table.clone(Provider, true)

	if type(builder) == "function" then
		class.builder = builder
	else
		class.builder = function()
			return builder
		end
	end

	local provider = gears.object({
		class = class,
		enable_properties = true,
		enable_auto_signals = true,
	})

	return provider
end

function m.consumer_widget(builder)
	local container = wibox.container.place()

	local function rebuild()
		local ref = {
			watch = function(target)
				return target:get(rebuild)
			end,
			read = function(target)
				return target.state
			end,
		}

		local child = builder(ref)
		container:set_widget(child)
	end

	rebuild()
	return container
end

return m
