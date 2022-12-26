-- TODO: make this module more robust incrementally
local awful = require("awful")
local naughty = require("naughty")
local gtable = require("gears.table")
local capi = {
	root = root,
	awesome = awesome,
}

local function get_active_sink()
	-- evil io.popen, but this command is quick tho
	-- convert to number because the new line at the end
	local active_sink 

	-- first attemp
	active_sink = tonumber(io.popen("pactl list short | grep RUNNING | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,'"):read("*a"))
	if active_sink == nil then
		-- second attemp, just use the first one
		active_sink = tonumber(io.popen("pactl list short | head -n 1 | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,'"):read("*a"))
	end
	-- last, just use default
	active_sink = active_sink or "@DEFAULT_SINK@"
	return active_sink
end

local function get_audio(line)
	if line:match("sink") == nil then
		return
	end

	local active_sink = get_active_sink()
	-- ic(active_sink)

	-- each sink section has about ~20 info line
	awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Sink \\#" .. active_sink .. "' -A 15", function(out)
		-- local cmd = "pactl list sinks | grep 'Sink \\#" .. active_sink .. "' -A 15"
		local volume = out:match("(%d+)%%") or -1
		local mute = out:match("Mute: yes") ~= nil
		local result = {mute = mute, volume = tonumber(volume)}
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
	XF86AudioMute = "pactl set-sink-mute 0 toggle",
	XF86AudioLowerVolume = "pactl set-sink-volume 0 -5%",
	XF86AudioRaiseVolume = "pactl set-sink-volume 0 +5%",
}

local keys = globalkeys
for key, cmd in pairs(commands) do
	local key = awful.key({}, key, function()
		awful.spawn.with_shell(cmd)
	end)
	keys = gtable.join(key, keys)
end
root.keys(keys)

get_audio("sink")

