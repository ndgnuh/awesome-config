local awful = require("awful")
local gears = require("gears")

-- commands to spawn when key is pressed
local cmd       = {}
cmd.mic_tog     = "amixer sset Capture toggle"
cmd.vol_tog     = "amixer_toggle"
cmd.vol_inc     = "amixer sset Master 4.99%+ unmute"
cmd.vol_dec     = "amixer sset Master 4.99%- unmute"
cmd.vol_get     = "amixer sget Master | grep %"
cmd.brn_inc     = "light -A 10"
cmd.brn_dec     = "light -U 10"
cmd.brn_get     = "light"
cmd.screen_conf = "arandr"
cmd.screenshot  = "gscreenshot"
cmd.fcursor     = "find-cursor --color '#03A9F4'"

-- signal to emit when the command is spawn
local signal = {}
signal.audio="volume::change"
signal.light="brightness::change"
signal.empty=nil

local config = {
	{ cmd = cmd.mic_tog,     signal = signal.audio, key = "XF86AudioMicMute"      },
	{ cmd = cmd.vol_tog,     signal = signal.audio, key = "XF86AudioMute"         },
	{ cmd = cmd.vol_inc,     signal = signal.audio, key = "XF86AudioRaiseVolume"  },
	{ cmd = cmd.vol_dec,     signal = signal.audio, key = "XF86AudioLowerVolume"  },
	{ cmd = cmd.brn_inc,     signal = signal.light, key = "XF86MonBrightnessUp"   },
	{ cmd = cmd.brn_dec,     signal = signal.light, key = "XF86MonBrightnessDown" },
	{ cmd = cmd.screen_conf, signal = signal.empty, key = "XF86Display"           },
	{ cmd = cmd.screenshot,  signal = signal.empty, key = "Print"                 },
}

local mediakeys = {}
for _, conf in ipairs(config) do
	mediakeys = gears.table.join(mediakeys,
		awful.key({}, conf.key, function()
			awful.spawn.easy_async_with_shell(conf.cmd, function(o)
				if conf.signal then awesome.emit_signal(conf.signal) end
			end)end))
end

root.keys(gears.table.join(root.keys(), mediakeys))
return { cmd = cmd, signal = signal }

