local gears = require"gears"
local awful = require"awful"

local color = require("gears.color")
notify = require("naughty").notify
local awful = require("awful")
local config_file = os.getenv("HOME") .. '/.config/awesome/configset.lua'

require("constant")
dpi = require("beautiful.xresources").apply_dpi

-------------------------
--  Change config set  --
-------------------------
function change_config_set(name)
  update_cmd = "cat " .. config_file .. " | sed 's/.*/require(\""..name.."\")/g' | tee " .. config_file
  awful.spawn.easy_async_with_shell(update_cmd, function ()
    awesome.restart()
  end)
end

------------------------
--  some global meno  --
------------------------
configsets = {
  { "Basic", function () change_config_set("basic") end },
  { "Guns girl", function () change_config_set("ggz") end },
  { "Fancy", function () change_config_set("fancy") end },
  { "Friendly", function () change_config_set("friendly") end },
  { "Default", function () change_config_set("default") end }
} -- config set

powermenu = {
  { "Shutdown", "systemctl poweroff" },
  { "Reboot", "systemctl reboot" },
  { "Hibernate", "systemctl hibernate" },
  { "Suspend", "systemctl suspend" },
  { "Logout", function() awesome.quit() end },
}
----------------------------------
--  color processing functions  --
----------------------------------
function rgbtohex(rgb)
  local hexadecimal = '#'

  for key, value in pairs(rgb) do
    local hex = ''

    while(value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub('0123456789ABCDEF', index, index) .. hex     
    end

    if(string.len(hex) == 0)then
      hex = '00'

    elseif(string.len(hex) == 1)then
      hex = '0' .. hex
    end

    hexadecimal = hexadecimal .. hex
  end
  return hexadecimal
end -- rgb_to_hex

function colormix(c1, c2, lv)
  local r1, g1, b1 = color.parse_color(c1)
  local r2, g2, b2 = color.parse_color(c2)
  local r = math.floor((255 * r1 * (1 - lv) + 255 * r2 * lv) + 0.5)
  local g = math.floor((255 * g1 * (1 - lv) + 255 * g2 * lv) + 0.5)
  local b = math.floor((255 * b1 * (1 - lv) + 255 * b2 * lv) + 0.5)
  return rgbtohex({r, g, b})
end -- color mixer

function colorcontrast(c)
  local r,g,b = color.parse_color(c)
  local luminate = 0.3*r + 0.587*g + 0.144*b
  if luminate > 0.5 then return "#32323D" else return "#fff5ee" end
end -- find contrast color

function colorinvert(c)
  local r,g,b = color.parse_color(c)
  return rgbtohex({
    math.floor(255 - r*255 + 0.5),
    math.floor(255 - g*255 + 0.5),
    math.floor(255 - b*255 + 0.5),
  })
end -- find invert color

-- require("draft")
require("configset")

-------------------------------------
--  volume and brightness binding  --
-------------------------------------
-- require("mediakeys")
-- require("mediapopup")

------------
--  misc  --
------------

function colormarkup(s, c)
  return '<span color=\'' .. c .. '\'>' .. s .. '</span>'
end --colour markup

modkey = "Mod4"
-- awful.screen.connect_for_each_screen(function(s)
--   awful.tag({1,"Web", "Term", "Doc", "Media", "Extra"}, s, awful.layout.layouts[1])
-- end)

globalkeys = gears.table.join(
  awful.key({modkey}, "j", function() ts:trigger() ts:emit_signal("forward") end),
  awful.key({modkey}, "k", function() ts:trigger() ts:emit_signal("backward") end),
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),
  awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
    {description = "swap with next client by index", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
    {description = "swap with previous client by index", group = "client"}),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    {description = "focus the next screen", group = "screen"}),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    {description = "focus the previous screen", group = "screen"}),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Shift"   }, "e", awesome.quit,
    {description = "quit awesome", group = "awesome"}),

  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    {description = "decrease master width factor", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),
  --    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
  --              {description = "select next", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    {description = "select previous", group = "layout"}),

  awful.key({ modkey, "Shift" }, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", {raise = true}
          )
      end
    end,
    {description = "restore minimized", group = "client"}),

  -- Prompt
  awful.key({ modkey }, "r",
    function()
      -- awful.screen.focused().mypromptbox:run() end,
      awful.spawn('rofi -show run')
    end,
    {description = "run prompt", group = "launcher"}),

  awful.key({ modkey }, "x",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    {description = "lua execute prompt", group = "awesome"}),
  -- Menubar
  awful.key({ modkey }, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})
  )

for i = 1,9 do
  globalkeys = gears.table.join(globalkeys,
    ---------------------
    --  view tag only  --
    ---------------------
    awful.key({mod}, "#" .. i + 9, function ()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
    end, {
      description = "view tag #"..i,
      group = "tag"
    }))
end

root.keys(gears.table.join(globalkeys, root.keys()))
