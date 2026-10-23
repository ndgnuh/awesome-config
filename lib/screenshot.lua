--- Wrapper around awful.screenshot.
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

return function(args)
	local ss_args = {
		directory = os.getenv("HOME") .. "/Pictures/Screenshots/",
		prefix = "somewm",
	}
	gears.table.crush(ss_args, args or {}, true)

	if ss_args.active_client and not ss_args.client then
		naughty.notification({
			title = "Screenshot",
			message = "No focused client for screenshot",
		})
		return
	end

	--- Nudge the client so that it updates
	--- Idk why QT clients need this
	local c = client.focus
	if c then
		-- Changing a floating client's size or cycling focus forces a Wayland commit
		local initial_floating = c.floating
		c.floating = true

		-- Nudge the client window by 1 pixel to force a buffer redraw
		local geo = c:geometry()
		c:geometry({ width = geo.width + 1 })
		c:geometry({ width = geo.width })
		c.floating = initial_floating
	end

	-- Give the application a few milliseconds to process the redraw before the snapshot
	local cb
	cb = function()
		-- Lmao disconnect it immediately, or face the consequence
		awesome.disconnect_signal("refresh", cb)

		local s = awful.screenshot(ss_args)
		s:refresh()

		s:connect_signal("file::saved", function(_, path)
			naughty.notification({
				title = "Screenshot taken",
				message = "The screenshot is saved at " .. path,
			})
			awful.spawn("snap_veneer " .. path)
		end)

		gears.timer.delayed_call(function()
			s:save()
		end)
	end
	awesome.connect_signal("refresh", cb)
end
