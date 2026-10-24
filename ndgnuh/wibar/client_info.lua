local wibox = require("wibox")
local overdrip = require("lib.overdrip")
local clients = require("providers.clients")

local m = {}

m.ClientIcon = overdrip.consumer_widget(function(ref)
	return wibox.widget.imagebox(ref.watch(clients.focused_icon_provider))
end)

m.ClientTitle = overdrip.consumer_widget(function(ref)
	local name = ref.watch(clients.focused_name_provider)
	return wibox.widget({
		widget = wibox.widget.textbox,
		align = "left",
		markup = name and ("<b>" .. name .. "</b>") or "",
	})
end)

return m
