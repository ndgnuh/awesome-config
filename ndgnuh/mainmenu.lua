local awful = require("awful")
local sp_wallpaper = require("lib.secondary_wallpaper")

local items = {
	{
		"Change wallpaper",
		function()
			sp_wallpaper:pick_wallpaper()
		end,
	},
	{ "Lock", awesome.lock },
	{ "Restart", awesome.restart },
	{ "Quit", awesome.quit },
}

local menu = awful.menu({
	items = items,
})

awesome.connect_signal("show-main-menu", function()
	mymainmenu:show()
end)

return menu
