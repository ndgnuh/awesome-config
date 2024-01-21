local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local capi = {
	client = client,
}

local lazy_task_list = function(args)
	local layout = args.layout
	local filter = args.filter or function(...)
		return true
	end
	local s = args.screen
	local w = wibox.widget({
		layout = args.layout,
		id = "root",
	})

	function w.update()
		local clients = {}
		for s in screen.clients do
		end
	end
end

local switchers = gears.cache(function(s)
	local switcher = {}
	local widget = wibox.widget({
		widget = wibox.layout.stack,
		{
			widget = wibox.container.background,
			bg = "#f00",
			forced_height = 50,
			wibox.widget.textbox("asdasd"),
		},
	})
	local popup = awful.popup({
		placement = awful.placement.centered,
		visible = true,
		ontop = true,
		widget = widget,
	})

	switchers.popup = popup
	return popup
end)

local function task_switcher(s)
	s = s or awful.screen.focused()
	local ts = switchers:get(s)
	return ts
end

return {
	task_switcher = task_switcher,
}
