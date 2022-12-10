local awful = require("awful")
local naughty = require("naughty")
local gtable = require("gears.table")
local capi = {
	root = root,
	awesome = awesome,
}

local function get_audio(line)
	if line:match("sink") == nil then
		return
	end
	awful.spawn.easy_async_with_shell("pactl list sinks", function(out)
		local volume = out:match("(%d+)%%")
		local mute = out:match("Mute: yes") ~= nil
		local result = {mute = mute, volume = volume}
		capi.awesome.emit_signal("extra::volume", result)
	end)
end

local pid = awful.spawn.with_line_callback("pactl subscribe", {
	stdout = get_audio 
})

capi.awesome.connect_signal("exit", function ()
	awful.spawn("kill -9 " .. pid)
end)


local commands = {
	XF86AudioMute = "pactl set-sink-mute @DEFAULT_SINK@ toggle",
	XF86AudioLowerVolume = "pactl set-sink-volume @DEFAULT_SINK@ -5%",
	XF86AudioRaiseVolume = "pactl set-sink-volume @DEFAULT_SINK@ +5%",
}

local keys = globalkeys
for key, cmd in pairs(commands) do
	local key = awful.key({}, key, function()
		awful.spawn(cmd)
	end)
	keys = gtable.join(key, keys)
end
root.keys(keys)

get_audio("sink")

