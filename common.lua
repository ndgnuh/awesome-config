local awful = require"awful"
local gears = require"gears"
local wm = require"helper.wm"
local partial = require"util.Partial"
local mm = require"util.MultiMethod2"
local Val = require"util.Val"
local db = require"util.Debug"

local module = gears.object{class = {
  __datatype = "Module",
  Default = {__datatype = "Default"}
}}

--- module.dispatches {{{
-- keys = signals, values = function to call
-- Why use signal? So that other widget can intercept.
-- This table contains dispatches which is used by every rice.
-- * To change behaviour for one rice, do it in the rice, THEN call setup()
-- * To change behaviour for all rices, change the behavior here
-- The need to call setup() will be remove in the future by
-- using a proxy for (dis)connecting dispatches from the module
local IBus = require"IBus"
local spawn = function(x) awful.spawn(x) end
local focus = awful.client.focus
local focusedtoggle = function(prop)
  local c = client.focus
  if c then c[prop] = not c[prop] end
  return prop
end
local focusedcall = function(method)
  local c = client.focus
  local f = c and c[method] or nil
  if f then f(c) end
  return method
end
module.dispatches = {
  ["app/launcher"] = partial(spawn, "rofi -show run"),
  ["app/menu"] = partial(spawn, "rofi -show run"),
  ["app/terminal"] = partial(spawn, "x-terminal-emulator"),
  ["wm/restart"] = awesome.restart,
  ["wm/quit"] = awesome.quit,
  ["client/focus-next"] = partial(focus.byidx, 1),
  ["client/focus-previous"] = partial(focus.byidx, -1),
  ["client/focus-last"] = partial(focus.history, -1),
  ["client/restore"] = awful.client.restore,
  ["client/toggle-maximize"] = partial(focusedtoggle, "maximized"),
  ["client/toggle-fullscreen"] = partial(focusedtoggle, "fullscreen"),
  ["client/toggle-floating"] = partial(focusedtoggle, "floating"),
  ["client/toggle-mark"] = partial(focusedtoggle, "marked"),
  ["client/minimize"] = partial(focusedtoggle, "minimized"),
  ["client/kill"] = partial(focusedcall, "kill"),
  ["media/audio+"] = partial(spawn, "pactl set-sink-volume @DEFAULT_SINK@ +5%"),
  ["media/audio-"] = partial(spawn, "pactl set-sink-volume @DEFAULT_SINK@ -5%"),
  ["media/audio!"] = partial(spawn, "pactl set-sink-mute @DEFAULT_SINK@ toggle"),
  ["media/micro+"] = partial(spawn, "pactl set-source-volume @DEFAULT_SOURCE@ +5%"),
  ["media/micro-"] = partial(spawn, "pactl set-source-volume @DEFAULT_SOURCE@ -5%"),
  ["media/micro!"] = partial(spawn, "pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
  ["media/brightness+"] = partial(spawn, "light -A 10"),
  ["media/brightness-"] = partial(spawn, "light -U 10"),
  ["media/display"] = partial(awful.spawn.raise_or_spawn, "arandr"),
  ["debug/test-signal"] = partial(db.dump, "Test signal"),

  ["misc/ibus-cycle"] = partial(IBus.cycle, IBus, {"xkb:us::eng", "Bamboo"})
}--}}}

--- setup{{{
-- connect signals from the rice
module.setup = function(self, mode, keys)
  keys = keys or self.keys
  for sig, func in pairs(self.dispatches) do
    if func then
      self:connect_signal(sig, function(self, ...)
        func(...)
      end)
    end
  end
  local actualkeys = {}
  local thekey
  for _, keypack in ipairs(keys) do
    if keypack.arg then
      thekey = awful.key(keypack[1], keypack[2], function()
        self:emit_signal(keypack[3], keypack.argf())
      end, keypack[4])
    else
      thekey = awful.key(keypack[1], keypack[2], function()
        self:emit_signal(keypack[3])
      end, keypack[4])
    end
    actualkeys = gears.table.join(actualkeys, thekey)
  end
  if mode == "a" then
    root.keys(root.keys(), actualkeys)
  else
    root.keys(actualkeys)
  end
end
--}}}

local modkey = "Mod4"
local Mod = {modkey}
local ModShift = {modkey, "Shift"}
local ModCtrl = {modkey, "Control"}
module.keys = {
  __datatype = "Keys",

  -- app related
  {Mod, "Return", "app/terminal"},
  {Mod, "w", "app/menu"},
  {Mod, "r", "app/launcher"},

  -- wm related
  {ModShift, "r", "wm/restart"},
  {ModShift, "e", "wm/quit"},

  -- client related
  {Mod, "j", "client/focus-next"},
  {Mod, "k", "client/focus-previous"},
  {ModShift, "q", "client/kill"},
  {Mod, "m", "client/toggle-maximize"},
  {Mod, "f", "client/toggle-fullscreen"},
  {ModShift, "f", "client/toggle-floating"},
  {ModShift, "m", "client/toggle-mark"},
  {Mod, "n", "client/minimize"},
  {ModShift, "n", "client/restore"},

  -- misc
  {Mod, "space", "misc/ibus-cycle"},

  -- media keys related
  {Nothing, "XF86AudioRaiseVolume", "media/audio+"},
  {Nothing, "XF86AudioLowerVolume", "media/audio-"},
  {Nothing, "XF86AudioMute", "media/audio!"},
  {Nothing, "XF86MonBrightnessUp", "media/brightness+"},
  {Nothing, "XF86MonBrightnessDown", "media/brightness-"},
  {Nothing, "XF86Display", "media/display"},
}

--do{{{
--  local Nothing = {}
--  local focusedtoggle = function(prop)
--    local c = client.focus
--    if c then c[prop] = not c[prop] end
--    return prop
--  end
--  local focusedcall = function(method)
--    local c = client.focus
--    local f = c and c[method] or nil
--    if f then f(c) end
--    return method
--  end
--  local modkey = "Mod4"
--  local Mod = {modkey}
--  local ModShift = {modkey, "Shift"}
--  local ModCtrl = {modkey, "Control"}
--  local key, spawn = awful.key, awful.spawn
--  local globalkeys = gears.table.join(
--
--
--  key(Mod, "j", partial(awful.client.focus.byidx, 1)),
--  key(Mod, "k", partial(awful.client.focus.byidx, -1)),{{{
--  key(ModShift, "n", awful.client.restore),
--  key(Mod, "r", partial(spawn, "rofi -show run")),
--  key(Mod, "w", partial(spawn, "rofi -show run")),
--  key(Mod, "Return", partial(spawn, "x-terminal-emulator")),
--  key(ModShift, "r", awesome.restart),
--
--  key(Mod, "m", partial(focusedtoggle, "maximized")),
--  key(Mod, "f", partial(focusedtoggle, "fullscreen")),
--  key(Mod, "n", partial(focusedtoggle, "minimized")),
--  key(ModShift, "q", partial(focusedmethod, "kill")),
--
--  key(Nothing, "XF86AudioRaiseVolume", partial(spawn, "pactl set-sink-volume @DEFAULT_SINK@ +5%")),
--  key(Nothing, "XF86AudioLowerVolume", partial(spawn, "pactl set-sink-volume @DEFAULT_SINK@ -5%")),
--  key(Nothing, "XF86AudioMute", partial(spawn, "pactl set-sink-mute @DEFAULT_SINK@ toggle")),
--  key(Nothing, "XF86MonBrightnessUp", partial(spawn, "light -A 10")),
--  key(Nothing, "XF86MonBrightnessDown", partial(spawn, "light -U 10")),
--  key(Nothing, "XF86Display", partial(spawn.raise_or_spawn, "arandr")),
--  {})
--
--  --root.keys(globalkeys)
--end}}}}}}

return module
