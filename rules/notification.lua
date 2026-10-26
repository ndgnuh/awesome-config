-- Notification rules. Safe to re-run: existing rules are removed by id first.
-- Reload with: package.loaded["rules.notification"] = nil; require("rules.notification")
-- Match on app_name/title/urgency/category, set bg/fg/timeout/ignore/etc.
local awful = require("awful")
local ruled = require("ruled")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

ruled.notification.connect_signal("request::rules", function()
	-- Remove and add again
	ruled.notification.remove_rule("notification-base")
	ruled.notification.append_rule({
		id = "notification-base",
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
			-- Exact width so background_role fills the drawin (default "max" strategy shrinks to content)
			width = beautiful.notification_width or dpi(320),
		},
	})
end)

-- Per-app routing example: mute one app, bump urgency for another.
-- ruled.notification.append_rule {
--     rule       = { app_name = "Spotify" },
--     properties = { ignore = true },
-- }
-- ruled.notification.append_rule {
--     rule       = { app_name = "Slack", title = "@you" },
--     properties = { urgency = "critical" },
-- }
