local w = require("wibox.widget")
local c = require("wibox.container")
local capi = { awesome = awesome }

local name_to_lang = {
	["xkb:us::eng"] = "en",
	["Bamboo"] = "vi",
	["anthy"] = "jp",
}
local widget = w({
	widget = w.textbox,
	markup = "NA",
})

capi.awesome.connect_signal("ibus-engine", function(name)
	local txt = name_to_lang[name]
	widget.markup = txt:upper()
end)

return widget
