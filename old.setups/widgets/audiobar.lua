local widget = require("wibox.widget")
local container = require("wibox.container")
local capi = { awesome = awesome }

local audiobar = widget{
	widget = container.place,
	{
		widget = widget.textbox,
		text = "ABCDEF"
	}
}

return audiobar
