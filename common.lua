local awful = require("awful")
local gears = require("gears")
local wm = require"helper.wm"
local partial = require("util.Partial")
local mm = require"util.MultiMethod2"
local Val = require"util.Val"
local db = require"util.Debug"
local rules = require("rules")
local hprevious = require("history-previous")

-- {{{
local module = gears.object{class = {
  __datatype = "Module",
  Default = {__datatype = "Default"}
}}
-- }}}

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
local tagcall = function(method, i)
  local s = awful.screen.focused()
  local tag
  if i then
    tag = s.tags[i]
  else
    tag = awful.tag.selected()
  end
  if tag then
    tag[method](tag)
  end
end

local Stateful = require"Stateful"
local tagtoggle = Stateful(function(self)
  if self.__tag then
    self.__tag:view_only()
    self.__tag = nil
  else
    local t = awful.tag.selected()
    if t then
      self.__tag = t
      awful.tag.viewnone()
    end
  end
end)

module.dispatches = {
  ["app/launcher"] = partial(spawn, "rofi -show run"),
  ["app/menu"] = partial(spawn, "rofi -show run"),
  ["app/terminal"] = partial(spawn, "x-terminal-emulator"),
  ["wm/restart"] = awesome.restart,
  ["wm/quit"] = awesome.quit,
  ["client/focus-next"] = partial(focus.byidx, 1),
  ["client/focus-previous"] = partial(focus.byidx, -1),
  ["client/focus-last"] = partial(hprevious.swap, true),
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

  ["misc/ibus-cycle"] = partial(IBus.cycle, IBus, {"xkb:us::eng", "Bamboo"}),

  -- tag involved
  ["tag/view-1"] = partial(tagcall, "view_only", 1),
  ["tag/view-2"] = partial(tagcall, "view_only", 2),
  ["tag/view-3"] = partial(tagcall, "view_only", 3),
  ["tag/view-4"] = partial(tagcall, "view_only", 4),
  ["tag/view-5"] = partial(tagcall, "view_only", 5),
  ["tag/view-6"] = partial(tagcall, "view_only", 6),
  ["tag/view-7"] = partial(tagcall, "view_only", 7),
  ["tag/view-8"] = partial(tagcall, "view_only", 8),
  ["tag/view-9"] = partial(tagcall, "view_only", 9),
  ["tag/view-none"] = tagtoggle,
  ["client/move-to-tag"] = function(i)
    local c= client.focus
    if c then c:move_to_tag(i) end
  end,
}
--}}}

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
        self:emit_signal(keypack[3], unpack(keypack.arg))
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

-- common key {{{
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
  {Mod, "Tab", "client/focus-last"},
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

  -- tags related
  {Mod, "#19", "tag/view-none"},
  {Mod, "#10" , "tag/view-1"},
  {Mod, "#11", "tag/view-2"},
  {Mod, "#12", "tag/view-3"},
  {Mod, "#13", "tag/view-4"},
  {Mod, "#14", "tag/view-5"},
  {Mod, "#15", "tag/view-6"},
  {Mod, "#16", "tag/view-7"},
  {Mod, "#17", "tag/view-8"},
  {Mod, "#18", "tag/view-9"},
  {ModShift, "#10", "client/move-to-tag", arg = {1}},
  {ModShift, "#11", "client/move-to-tag", arg = {2}},
  {ModShift, "#12", "client/move-to-tag", arg = {3}},
  {ModShift, "#13", "client/move-to-tag", arg = {4}},
  {ModShift, "#14", "client/move-to-tag", arg = {5}},
  {ModShift, "#15", "client/move-to-tag", arg = {6}},
  {ModShift, "#16", "client/move-to-tag", arg = {7}},
  {ModShift, "#17", "client/move-to-tag", arg = {8}},
  {ModShift, "#18", "client/move-to-tag", arg = {9}},
}
-- }}}

-- basic layout {{{
awful.layout.layouts = {
  awful.layout.suit.max,
  awful.layout.suit.tile,
  awful.layout.suit.floating,
}
-- }}}

local beautiful = require("beautiful")
local gtable = require("gears.table")

local client_buttons = gtable.join(
awful.button(Nothing, 1, function(c)
  c:emit_signal("request::activate", "mouse", {raise = true})
end),
awful.button(Mod, 1, function(c)
  c:emit_signal("request::activate", "mouse", {raise = true})
  awful.mouse.client.move(c)
end),
awful.button(Mod, 3, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.resize(c)
end),
{})

-- all clients{{{
rules:add("default", {
  rule = { },
  properties = {
    -- border_width = beautiful.border_width,
    -- border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    raise = true,
    -- keys = clientkeys,
    buttons = client_buttons,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap+awful.placement.no_offscreen
  },
})
--}}}

-- floating clients rule{{{
rules:add("floating-clients", {
  rule_any = {
    instance = {
      "DTA",  -- Firefox addon DownThemAll.
      "copyq",  -- Includes session name in class.
      "pinentry",
    },
    class = {
      "Arandr",
      "Blueman-manager",
      "Gpick",
      "Kruler",
      "MessageWin",  -- kalarm.
      "Sxiv",
      "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
      "Wpa_gui",
      "veromix",
      "xtightvncviewer"
    },
    -- Note that the name property shown in xprop might be set slightly after creation of the client
    -- and the name shown there might not match defined rules here.
    name = {
      "Event Tester",  -- xev.
      "Picture-in-Picture", -- firefox picture in picture
    },
    role = {
      "AlarmWindow",  -- Thunderbird's calendar.
      "ConfigManager",  -- Thunderbird's about:config.
      "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
    }
  },
  properties = {
    floating = true
  },
})
--}}}

-- enable titlebar for clients{{{
rules:add("enable titlebar", {
  rule_any = { type = { "normal", "dialog" } },
  properties = { titlebars_enabled = true }
})
--}}}

return module
