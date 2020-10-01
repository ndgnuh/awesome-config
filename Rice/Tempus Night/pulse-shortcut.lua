local awful = require"awful"
local naughty = require"naughty"
local gears = require"gears"
local SingleNotification = require"common.SingleNotification"
local partial = require("Partial")

-- shortcut
local spnw = awful.spawn.easy_async_with_shell

-- object for signaling
local obj = gears.object()

local dispatches = {
  get      = "pactl list sinks"                          ,
  increase = "pactl set-sink-volume @DEFAULT_SINK@ +5%"  ,
  decrease = "pactl set-sink-volume @DEFAULT_SINK@ -5%"  ,
  toggle   = "pactl set-sink-mute @DEFAULT_SINK@ toggle" ,
}

--[[ @pactl_list_sinks_output {{{
Sink #0
  State: SUSPENDED
  Name: alsa_output.pci-0000_00_1f.3.analog-stereo
  Description: Built-in Audio Analog Stereo
  Driver: module-alsa-card.c
  Sample Specification: s16le 2ch 44100Hz
  Channel Map: front-left,front-right
  Owner Module: 6
  Mute: no
  Volume: front-left: 65183 /  99% / -0.14 dB,   front-right: 65183 /  99% / -0.14 dB
          balance 0.00
  Base Volume: 65536 / 100% / 0.00 dB
  Monitor Source: alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
  Latency: 0 usec, configured 0 usec
  Flags: HARDWARE HW_MUTE_CTRL HW_VOLUME_CTRL DECIBEL_VOLUME LATENCY 
  Properties:
    alsa.resolution_bits = "16"
    device.api = "alsa"
    device.class = "sound"
    alsa.class = "generic"
    alsa.subclass = "generic-mix"
    alsa.name = "ALC298 Analog"
    alsa.id = "ALC298 Analog"
    alsa.subdevice = "0"
    alsa.subdevice_name = "subdevice #0"
    alsa.device = "0"
    alsa.card = "0"
    alsa.card_name = "HDA Intel PCH"
    alsa.long_card_name = "HDA Intel PCH at 0xf1120000 irq 129"
    alsa.driver_name = "snd_hda_intel"
    device.bus_path = "pci-0000:00:1f.3"
    sysfs.path = "/devices/pci0000:00/0000:00:1f.3/sound/card0"
    device.bus = "pci"
    device.vendor.id = "8086"
    device.vendor.name = "Intel Corporation"
    device.product.id = "9d71"
    device.product.name = "Sunrise Point-LP HD Audio"
    device.form_factor = "internal"
    device.string = "front:0"
    device.buffering.buffer_size = "352800"
    device.buffering.fragment_size = "176400"
    device.access_mode = "mmap+timer"
    device.profile.name = "analog-stereo"
    device.profile.description = "Analog Stereo"
    device.description = "Built-in Audio Analog Stereo"
    alsa.mixer_name = "Realtek ALC298"
    alsa.components = "HDA:10ec0298,17aa5063,00100103 HDA:8086280b,80860101,00100000"
    module-udev-detect.discovered = "1"
    device.icon_name = "audio-card-pci"
  Ports:
    analog-output-speaker: Speakers (priority: 10000, not available)
    analog-output-headphones: Headphones (priority: 9900, available)
  Active Port: analog-output-headphones
  Formats:
    pcm
}}} ]]

-- default output to stdout handler
obj.mute  = true
obj.left  = 0
obj.right = 0

local matcher = {
  mute  = "%s*Mute:%s*(%a+)"                     ,
  right = "front%-right: *%d+ */ *(%d+)%%[^\n]*" ,
  left  = "front%-left: *%d+ */ *(%d+)%%[^\n]*"  ,
}

local notification = SingleNotification()
local stdHandler = function(stdout, stderr)
  if stderr and stderr ~= "" then
    naughty.notify {
      preset = naughty.preset.error ,
      title = "Pulse error"         ,
      text = tostring(stderr)    ,
    }
  else
    local mute = stdout:match(matcher.mute) == "yes"
    local right = stdout:match(matcher.right)
    local left = stdout:match(matcher.left)
    notification {
      title = "Pulse Audio",
      text = string.format (
        "Left: %s%%, Right: %s%%, Muted: %s" ,
        left                                 ,
        right                                ,
        mute                                 )
    }
  end
end

local dispatch =
  function(cmd)
    spnw(cmd, function()
      spnw(dispatches.get, stdHandler)
    end)
  end

root.keys (
  gears.table.join (
    awful.key ({}, "XF86AudioMute"       , partial(dispatch, dispatches.toggle  )),
    awful.key ({}, "XF86AudioRaiseVolume", partial(dispatch, dispatches.increase)),
    awful.key ({}, "XF86AudioLowerVolume", partial(dispatch, dispatches.decrease)),
    root.keys ()
  )
)
