local awful = require("awful")
local gtable = require("gears.table")

local keyconf = {
	-- {
	-- 	key = "XF86AudioRaiseVolume",
	-- 	cmd = "amixer set Master 5%+ unmute",
	-- },
	-- {
	-- 	key = "XF86AudioLowerVolume",
	-- 	cmd = "amixer set Master 5%- unmute",
	-- },
	-- {
	-- 	key = "XF86AudioMute",
	-- 	cmd = "pactl set-sink-mute 0 toggle",
	-- },
	{
		key = "XF86MonBrightnessUp",
		cmd = "light -A 10",
	},
	{
		key = "XF86MonBrightnessDown",
		cmd = "light -U 10",
	},
	{
		key = "Print",
		cmd = "gscreenshot",
	}
}

for _, key in pairs(keyconf) do
	root.keys(gtable.join(
		root.keys(),
		awful.key({}, key.key, function()
			awful.spawn.easy_async_with_shell(key.cmd, function(o)
			end)
		end)
	))
end


return true