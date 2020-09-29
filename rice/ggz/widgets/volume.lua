local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local api = require("api")
local common = require"common"

local widget_volume = wibox.widget({
   widget = wibox.widget.textbox,
   markup = '  ',
})

local markup = beautiful.whitetext
widget_volume:connect_signal(api.audio.signal.vol_update, function(_, status)
   if status.vol_muted then
      widget_volume.markup = markup("Muted")
   else
      widget_volume.markup = markup(status.vol_level .. "%")
   end
end)
api.audio.attach(widget_volume)

common:connect_signal("media/audio+", api.audio.update_vol)
common:connect_signal("media/audio-", api.audio.update_vol)
common:connect_signal("media/audio!", api.audio.update_vol)
api.audio.update_vol()
return widget_volume
