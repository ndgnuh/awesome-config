local wibox = require("wibox")
local gears = require("gears")
local m = {}

--- Create a notifier, which is just gears.object
function m.notifier(data)
	local state = gears.object({
		class = data,
		enable_properties = true,
		enable_auto_signals = true,
	})

	-- Store properties
	state.properties = {}
	for k, _ in pairs(data) do
		table.insert(state.properties, k)
	end

	return state
end

---Create a widget that listens to some notifier's signal
function m.consumer(args)
	local state = args.state
	local builder = args.builder

	-- List of signals to watch
	local signals
	if args.signals then
		signals = signals
	else
		signals = {}
		for _, property in ipairs(state.properties) do
			table.insert(signals, "property::" .. property)
		end
	end

	local first = builder(state)
	local mount = wibox.container.place(first)

	for _, signal in ipairs(signals) do
		state:connect_signal(signal, function()
			local updated = builder(state)
			mount.widget = updated
		end)
	end

	return mount
end

return m
