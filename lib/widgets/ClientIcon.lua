local gears = require("gears")
local awful = require("awful")
local client = _G.client
local ClientIcon = {}

ClientIcon.new = function()
	local client_icon = awful.titlebar.widget.iconwidget({})

	local update_client_info = function(_)
		gears.timer.delayed_call(function()
			local c = client.focus
			client_icon:set_client(c)
		end)
	end

	client.connect_signal("focus", update_client_info)
	client.connect_signal("unfocus", update_client_info)
	client.connect_signal("unmanage", update_client_info)
	client.connect_signal("property::name", update_client_info)
	client.connect_signal("property::class", update_client_info)

	return client_icon
end

return setmetatable(ClientIcon, {
	__call = function(self)
		return self.new()
	end,
})
