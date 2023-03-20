
-- TODO: make this module more robust incrementally
-- imports {{{
local awful = require("awful")
local naughty = require("naughty")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local capi = {
	root = root,
	awesome = awesome,
}
-- }}}

local M = { pulse = {} }

-- do not emit signal

-- pulseaudio interact function
-- get active sink
M.pulse.get_active_sink = function(callback)
	local cmd = "pactl list short | grep RUNNING | grep -v monitor | head -n 1 | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,'"
	awful.spawn.with_shell(cmd, function(so)
		callback(tonumber(so))
	end)
end

-- get current audio
M.pulse.get_audio = function(sink, callback)
	local cmd
	if sink ~= nil then
		cmd = "pactl set-sink-volume " .. sink .. " " .. change
	else
		cmd = "pactl set-sink-volume @DEFAULT_SINK@ " .. change
	end
	awful.spawn.easy_async_with_shell(cmd, function(out)
		local volume = out:match("(%d+)%%") or -1
		local mute = out:match("Mute: yes") ~= nil
		local result = {mute = mute, volume = tonumber(volume)}
		callback(result)
	end)
end

local function get_active_sink()
	-- evil io.popen, but this command is quick tho
	-- convert to number because the new line at the end
	local active_sink 

	-- first attemp
	active_sink = tonumber(io.popen("pactl list short | grep RUNNING | grep -v monitor | head -n 1 | sed -e 's,^\\([0-9][0-9]*\\)[^0-9].*,\\1,'"):read("*a"))
	return active_sink
end

-- commands {{{
local cmd = {}

cmd.get_audio  = function()
	local sink = get_active_sink()
	if sink ~= nil then
		return "pactl list sinks | grep 'Sink \\#" .. sink .. "' -A 15"
	else
		return "pactl list sinks "
	end
end

cmd.set_audio = function(change)
	if sink ~= nil then
		return "pactl set-sink-volume " .. sink .. " " .. change
	else
		return "pactl set-sink-volume @DEFAULT_SINK@ " .. change
	end
end

cmd.toggle_audio = function(change)
	change = change or "toggle"
	if sink ~= nil then
		return "pactl set-sink-mute " .. sink .. " " .. change
	else
		return "pactl set-sink-mute @DEFAULT_SINK@ " .. change
	end
end
---}}}

--- functions {{{
local fn = {}
fn.raise_volume = function()
	awful.spawn.easy_async(cmd.set_audio("+5%"), false)
end
fn.lower_volume = function()
	awful.spawn.easy_async(cmd.set_audio("-5%"), false)
end
fn.toggle_mute = function()
	awful.spawn.easy_async(cmd.toggle_audio(), false)
end


-- }}}

local function get_audio(line)
	if line:match("sink") == nil then
		return
	end

	-- each sink section has about ~20 info line
	awful.spawn.easy_async_with_shell(cmd.get_audio(), function(out)
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
	XF86AudioMute = fn.toggle_mute,
	XF86AudioLowerVolume = fn.lower_volume,
	XF86AudioRaiseVolume = fn.raise_volume
}

local keys = globalkeys
for key, fn in pairs(commands) do
	local key = awful.key({}, key, fn)
	keys = gtable.join(key, keys)
end
root.keys(keys)

get_audio("sink")

return {
	on_change = function(callback)
		capi.awesome.connect_signal("extra::volume", function(volume)
			callback(volume)
		end)
	end
}

-- vim: foldmethod=marker
