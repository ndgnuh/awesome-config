local beautiful = require("beautiful")
local awful = require("awful")

local themes = {
	"material-dark",
	"nord",
}

local current = 1
local prefix = os.getenv("HOME") .. "/.config/awesome/"
local rcdir = prefix .. "rc/"

beautiful.init(prefix .. "themes/" .. themes[current] .. "/theme.lua")
require("themes." .. themes[current])

function change_theme_cmd(index)
	cmd = "cat themes.lua | sed 's/current = [[:digit:]]/current = "
	cmd = cmd .. index
	cmd = cmd .. "/g | tee "
	cmd = cmd .. rcdir .. "themes.lua"
	return cmd
end

function change_theme(index)
	cmd = change_theme_cmd(index)
	awful.spawn.easy_async_with_shell(cmd, function()
		awesome.restart()
	end)
end

return current
