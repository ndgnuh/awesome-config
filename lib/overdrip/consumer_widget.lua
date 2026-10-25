local wibox = require("wibox")
local Provider = require.rel("provider")

---Create a widget that rebuilds its child whenever a watched provider changes.
---@param builder fun(ref: overdrip.Ref): any Return the child widget
local function consumer_widget(builder)
	local container = wibox.container.place()

	local provider = Provider.new(function(ref)
		local child = builder(ref)
		container:set_widget(child)
		return child
	end)

	-- Dependents are weak references, keep the provider alive with the widget
	container._overdrip_provider = provider
	provider:flush()

	return container
end

return consumer_widget
