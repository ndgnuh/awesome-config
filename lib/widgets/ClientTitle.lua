local gears = require("gears")
local wibox = require("wibox")
local client = _G.client
local ClientTitle = {}

ClientTitle.new = function()
	local client_title = wibox.widget({
		widget = wibox.widget.textbox,
		align = "left",
	})

	local update_client_info = function(_)
		gears.timer.delayed_call(function()
			local c = client.focus
			if c then
				client_title:set_markup("<b>" .. tostring(c.name or c.class or "Untitled window") .. "</b>")
			else
				client_title:set_markup("")
			end
		end)
	end

	client.connect_signal("focus", update_client_info)
	client.connect_signal("unfocus", update_client_info)
	client.connect_signal("unmanage", update_client_info)
	client.connect_signal("property::name", update_client_info)
	client.connect_signal("property::class", update_client_info)

	return client_title
end

return setmetatable(ClientTitle, {
	__call = function(self)
		return self.new()
	end,
})
