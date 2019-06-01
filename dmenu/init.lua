local awful = require("awful")
local gtable = require("gears.table")
local notify = require("naughty").notify

local prefix = os.getenv("HOME") .. "/.config/awesome/dmenu/"
local dmenu = {
	project = "dmenu_project.sh"
}

local rootkeys = root.keys()
rootkeys = gtable.join(rootkeys,
	awful.key({ "Mod1", "Shift" }, "Return", function()
		awful.spawn(prefix .. dmenu.project)
	end))


root.keys(rootkeys)

