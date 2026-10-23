local m = {}
local naughty = require("naughty")

naughty.set_suspended(false)

m.toggle = function()
	naughty.suspended = not naughty.suspended

	naughty.notification({
		title = "Notifications",
		text = naughty.suspended and "Do Not Disturb" or "Notification resumed",
		timeout = 2,
		ignore_suspend = true,
	})
end

-- Menu item for menu
m.menuitem = {
	"Toggle notification",
	m.toggle,
}

return m
