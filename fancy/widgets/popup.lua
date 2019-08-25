local gears = require("gears")
-- local beautiful = require("beautiful")
local naughty = require("naughty")
local audio = require("api.audio")
local brightness = require("api.brightness")
-- local awful = require("awful")
-- local wibox = require("wibox")

local object = gears.object()

object.notification = naughty.notify({
      title = "asdasd",
      message = "abc",
      timeout = 5,
      ignore = true,
      ignore_suspend = true,
})

audio.attach(object)
brightness.attach(object)

local function popup(ntype, data)
   local icon = nil
   local message = nil
   local title = nil
   if ntype == "volume" then
      title = "Volume"
      message = data.vol_muted and "Volume muted" or "Volume: " .. data.vol_level .. "%"
   elseif ntype == "mic" then
      title = "Microphone"
      message = data.mic_muted and "Microphone muted" or "Microphone: " .. data.mic_level
   else
      title = "Brightness"
      message = "Brightness " .. data .. "%"
   end
   naughty.destroy(object.notification)
   object.notification = naughty.notification{
      title = title,
      message = message,
      width = 256,
      height = 64,
      replaces_id = object.notification.id,
      timeout = 5,
   }
end

object:connect_signal(audio.signal.vol_update, function(w, dat)
   if w.firstrun then w.firstrun = false return end
   popup("volume", dat)
end)

object:connect_signal(audio.signal.mic_update, function(w, dat)
   if w.firstrun then w.firstrun = false return end
   popup("mic", dat)
end)

object:connect_signal(brightness.signal.update, function(w, dat)
   if w.firstrun then w.firstrun = false return end
   popup("brightness", dat)
end)
