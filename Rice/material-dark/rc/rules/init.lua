local gears = require("gears")
local awful = require("awful")

local prefix = "rc.rules."
local rules = {
	"default",
	"web",
	-- "code"
}

for _, rule in pairs(rules) do
	awful.rules.rules = gears.table.join(
		awful.rules.rules,
		require(prefix..rule)
	)
end
