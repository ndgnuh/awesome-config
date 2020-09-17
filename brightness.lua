--[[ @requirements --]]
local sh = re"sh"
local ic = re"icon"
local awful = re"awful"
local naughty = re"naughty"
local timer = re"gears.timer"

local exp = math.exp
local min = math.min

--[[ @brightness_delta
The amount of change in brightness
--]]
local defaultDelta = 5
local delta = 5
local beta = 0.1
local deltaResetTimer = timer{
	timeout = 2,
	callback = function() delta = defaultDelta end
}
local deltaAcceleration = function()
	delta = min(delta * exp(beta), 30)
end

--[[ @notification
Make a notification that either
create new or replace the current one
--]]
local notification = false
local notifyOrNot = function(title, detail)
	if not notification or notification.dismissed then
		notification = naughty.notify{
			icon = ic"gtk-close.svg",
			title = title,
			detail = detail,
		}
	else
		naughty.reset_timeout(notification, 4)
	end
	naughty.replace_text(notification, title, detail)
end
local notificationCallback = function(stdout, stderr)
	if stderr and stderr ~= "" then --[[ if error ]]
		notifyOrNot("AwesomeWM", stderr)
	else --[[ if not error ]]
		notifyOrNot("AwesomeWM", string.format("Brightness: %s", stdout or "unknown"))
	end
end

--[[ @command_callback
Callback for sh call
--]]
local callback = function(stdout, stderr)
	notificationCallback(stdout, stderr)
	deltaAcceleration()
	deltaResetTimer:again()
end

sh:connect_signal("brightness.sh", callback)

--[[ @brightness_key_binding
Add key binding to the global key
--]]
awful.add_key_binding(
	awful.key({}, "XF86MonBrightnessUp", function()
		sh("brightness.sh inc " .. delta)
	end),
	awful.key({}, "XF86MonBrightnessDown", function()
		sh("brightness.sh dec " .. delta)
	end),
	--[[ add key binding --]]{})

