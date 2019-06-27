local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local widget_volume = wibox.widget({
   widget = wibox.widget.textbox,
   font = beautiful.boldfont,
   markup = '  ',
})

local function update_widget()
   awful.spawn.easy_async(CMD_VOL_GET, function(o)
      -- Sample output
      -- Mono: Playback 63 [50%] [-32.00dB] [on]
      lv, stat = string.match(o, ".*%[(%d%d?%d?)%%%].*%[(%a*)].*")
      if stat == "on" then
         widget_volume.markup = '<span color=\'' .. beautiful.white .. '\'>' .. lv .. '%</span>'
      else
         widget_volume.markup = '<span color=\'' .. beautiful.white .. '\'>muted</span>'
      end
   end)
end

update_widget()
awesome.connect_signal(SIG_AUDIO, function() update_widget() end)

return widget_volume
