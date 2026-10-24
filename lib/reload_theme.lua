local beautiful = require("beautiful")
local naughty = require("naughty")

local m = {}

m.reload = function()
	-- Drop the cached module so require re-reads the theme file
	package.loaded["ndgnuh.theme"] = nil
	beautiful.init(require("ndgnuh.theme"))

	naughty.notification({
		title = "Theme",
		text = "Theme reloaded",
		timeout = 2,
	})
end

-- Menu item for menu
m.menuitem = {
	"Reload theme",
	m.reload,
}

return m
