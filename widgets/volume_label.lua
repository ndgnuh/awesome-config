local wibox = require("wibox")


local volume_label = wibox.widget{
	id = "text",
	widget = wibox.widget.textbox,
	markup = "",
	font = "monospace",
}

awesome.connect_signal("extra::volume", function(status)
	if status.mute then
		volume_label.markup = "M"
	else
		volume_label.markup = status.volume
	end
end)

local volume_label_widget = wibox.widget{
	widget = wibox.container.place,
	volume_label
}

return volume_label_widget
