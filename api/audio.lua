local awful = require("awful")
local gears = require("gears")

-- {{ commands
local AUDIO_VOL_TOGGLE = "amixer sset Master toggle"
local AUDIO_VOL_GET    = [[pactl list sinks | grep -P '^\s*(Volume):[^,]*([0-9]+%)+|(Mute): (no)' -o | sed 's/\s*front-left: *[0-9]* *\/ *\|\s\|%//g' | sed 's/no/false/' | awk -F":" '{print "local " (lower $1) " = " $2}; END {print "return Volume, Mute"}']]
local AUDIO_VOL_UP     = "amixer sset Master 10%+ unmute"
local AUDIO_VOL_DOWN   = "amixer sset Master 10%- unmute"
local AUDIO_VOL_SET    = "amixer sset Master "
local AUDIO_MIC_TOGGLE = "amixer sset Capture toggle"
local AUDIO_MIC_GET    = "amixer sget Capture | grep %"
local AUDIO_MIC_UP     = "amixer sset Capture 10%+ unmute"
local AUDIO_MIC_DOWN   = "amixer sset Capture 10%- unmute"
local AUDIO_MIC_SET    = "amixer sset Capture "
--commands }}

-- {{ XF keys
local AUDIO_KEY_VOL_UP     = "XF86AudioRaiseVolume"
local AUDIO_KEY_VOL_DOWN   = "XF86AudioLowerVolume"
local AUDIO_KEY_VOL_TOGGLE = "XF86AudioMute"
local AUDIO_KEY_MIC_TOGGLE = "XF86AudioMicMute"
-- XF keys }}

local audio = {
	signal = {
		vol_update = "audio::vol_update",
		mic_update = "audio::mic_update"
	},
	widget = {},
	status = {
		vol_level = 0,
		mic_level = 0,
		vol_muted = false,
		mic_muted = false,
	},
	key = {},
}

function audio.set_step(step)
	AUDIO_VOL_UP   = "amixer sset Master " .. step .. "%+ unmute"
	AUDIO_VOL_DOWN = "amixer sset Master " .. step .. "%- unmute"
	AUDIO_MIC_UP   = "amixer sset Capture " .. step .."%+ unmute"
	AUDIO_MIC_DOWN = "amixer sset Capture " .. step .."%- unmute"
end

function audio.update_mic()
	awful.spawn.easy_async_with_shell(AUDIO_MIC_GET, function(stdout)
		-- Sample output
		-- Mono: Playback 63 [50%] [-32.00dB] [on]
		local lv, stat = string.match(stdout, ".*%[(%d%d?%d?)%%%].*%[(%a*)].*")
		local muted = nil
		if stat == 'on' then muted = false else muted = true end
		audio.status.mic_level = lv
		audio.status.mic_muted = muted
		for i=1,#audio.widget do
			audio.widget[i]:emit_signal(audio.signal.mic_update, audio.status)
		end
	end)
end

function audio.update_vol()
	awful.spawn.easy_async_with_shell(AUDIO_VOL_GET, function(stdout)
		-- Sample output
		-- Mono: Playback 63 [50%] [-32.00dB] [on]
		local lv, muted = load(stdout)()
		audio.status.vol_level = lv
		audio.status.vol_muted = muted
		for i=1,#audio.widget do
			audio.widget[i]:emit_signal(audio.signal.vol_update, audio.status)
		end
	end)
end

function audio.vol_increase() awful.spawn.easy_async(AUDIO_VOL_UP,         audio.update_vol) end
function audio.vol_decrease() awful.spawn.easy_async(AUDIO_VOL_DOWN,       audio.update_vol) end
function audio.vol_toggle()   awful.spawn.easy_async(AUDIO_VOL_TOGGLE,     audio.update_vol) end
function audio.vol_set(level) awful.spawn.easy_async(AUDIO_VOL_SET..level, audio.update_vol) end
function audio.mic_toggle()   awful.spawn.easy_async(AUDIO_MIC_TOGGLE,     audio.update_mic) end
function audio.mic_increase() awful.spawn.easy_async(AUDIO_MIC_UP,         audio.update_mic) end
function audio.mic_decrease() awful.spawn.easy_async(AUDIO_MIC_DOWN,       audio.update_mic) end
function audio.mic_set(level) awful.spawn.easy_async(AUDIO_MIC_SET..level, audio.update_vol) end

function audio.attach(widget, callback)
	audio.widget[#audio.widget + 1] = widget
	audio.update_vol()
	if type(callback) == "function" then callback() end
end

audio.key = gears.table.join(audio.key,
	awful.key({}, AUDIO_KEY_VOL_UP, audio.vol_increase),
	awful.key({}, AUDIO_KEY_VOL_DOWN, audio.vol_decrease),
	awful.key({}, AUDIO_KEY_VOL_TOGGLE, audio.vol_toggle),
	awful.key({}, AUDIO_KEY_MIC_TOGGLE, audio.mic_toggle),
	awful.key({"Mod1"}, AUDIO_KEY_VOL_UP, audio.mic_increase),
	awful.key({"Mod1"}, AUDIO_KEY_VOL_DOWN, audio.mic_decrease)
)

return audio
