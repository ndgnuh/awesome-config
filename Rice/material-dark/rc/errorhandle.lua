local naughty = require("naughty")

if awesome.startup_errors then
	naughty.notification {
	    preset  = naughty.config.presets.critical,
	    title   = "Oops, there were errors during startup!",
	    message = awesome.startup_errors
	}
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
	    -- Make sure we don't go into an endless error loop
	    if in_error then return end
	    in_error = true

	    naughty.notification {
		preset  = naughty.config.presets.critical,
		title   = "Oops, an error happened!",
		message = tostring(err)
	    }

	    in_error = false
	end)
end