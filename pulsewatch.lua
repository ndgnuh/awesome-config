local awful = require("awful")

awful.spawn.with_line_callback("pactl subscribe", {
	stdout = function(line)
		awesome.emit("pulseaudio")
	end,
})
