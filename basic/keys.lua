local gears = require("gears")
local awful = require("awful")
------------------------------------------------------------------------
--                         binding: keyboard                          --
------------------------------------------------------------------------
mod = mod or "Mod1"
local key_root = gears.table.join(
   awful.key({mod}, '/', function() popup_hotkeys.show_help(nil, awful.screen.focused()) end, {
      description = 'Show/hide help',
      group = 'Awesome'
   }),
   awful.key({mod}, 'w', function() menu:show() end, {
      description = 'Open context menu',
      group = 'Awesome'
   }),
   awful.key({mod}, 's', function() awful.screen.focus_relative(1) end, {
      description = 'Focus next screen',
      group = 'Awesome'
   }),
   awful.key({mod}, 'j', function() awful.client.focus.byidx(1) end, {
      description = 'Focus next client',
      group = 'Client'
   }),
   awful.key({mod}, 'k', function() awful.client.focus.byidx(-1) end, {
      description = 'Focus previous client',
      group = 'Client'
   }),
   awful.key({mod}, "l", function() awful.tag.incmwfact( 0.05) end, {
      description = "Increase master width factor",
      group = "Layout"
   }),
   awful.key({mod}, "h", function() awful.tag.incmwfact(-0.05) end, {
      description = "Decrease master width factor",
      group = "Layout"
   }),
   awful.key({mod}, 'Return', function() awful.spawn(terminal) end, {
      description = 'Spawn terminal',
      group = 'Awesome'
   }),
   awful.key({mod}, 'space', function() awful.layout.inc(1) end, {
      description = 'Next layout',
      group = 'Awesome'
   }),
   awful.key({mod, 'Shift'}, 'r', awesome.restart, {
      description = 'Restart awesome',
      group = 'Awesome',
   }),
   awful.key({mod, 'Shift'}, 'n', function()
      local c = awful.client.restore()
      if c then
         c:emit_signal("request::active", "key.unminimize", {
            raise = true
         })
      end
   end, {
      description = "Restore minimized client",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "j", function()
      awful.client.swap.byidx(1)
   end, {
      description = "swap with next client by index",
      group = "client"
   }),
   awful.key({mod, "Shift"}, "k", function()
      awful.client.swap.byidx(-1)
   end, {
      description = "swap with previous client by index",
      group = "client"
   })
) -- key_root

for i = 1,9 do
   key_root = gears.table.join(
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
      }),
      --------------------------
      --  toggle tag display  --
      --------------------------
      awful.key({mod, "Control"}, "#" .. i + 9, function ()
         local screen = awful.screen.focused()
         local tag = screen.tags[i]
         if tag then
            awful.tag.viewtoggle(tag)
         end
      end, {
         description = "toggle tag #" .. i,
         group = "tag"
      }),
      --------------------------
      --  move client to tag  --
      --------------------------
      awful.key({mod, "Shift"}, "#" .. i + 9, function ()
         if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
               client.focus:move_to_tag(tag)
            end
         end
      end, {
         description = "move focused client to tag #"..i,
         group = "tag"
      })
   , key_root) -- key_root
end

local key_client = gears.table.join(
   awful.key({mod}, 'f', function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
   end, {
      description = "Toggle fullscreen",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "q", function(c) c:kill() end, {
      description = "Close",
      group = "Client"
   }),
   awful.key({mod, "Control"}, "space", awful.client.floating.toggle, {
      description = "Toggle floating",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "s", function(c) c:move_to_screen() end, {
      description = "Move to screen",
      group = "Client"
   }),
   awful.key({mod,},"t",function(c) c.ontop = not c.ontop end,  {
      description = "Toggle keep on top",
      group = "Client"
   }), 
   awful.key({mod, }, "n", function(c) c.minimized = true end, {
      description = "Minimize client",
      group = "Client"
   }),
   awful.key({mod}, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
   end, {
      description = "Toggle maximize",
      group = "Client"
   }),
   awful.key({mod, "Control"}, "m", function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
   end, {
      description = "Toggle maximize vertically",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "m", function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
   end, {
      description = "Toggle maximize horizontally",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "j", function()
      awful.client.swap.byidx(1)
   end, {
      description = "swap with next client by index",
      group = "Client"
   }),
   awful.key({mod, "Shift"}, "k", function()
      awful.client.swap.byidx(-1)
   end, {
      description = "swap with previous client by index",
      group = "Client"
   }),
   awful.key({mod, 'Shift'}, 'space', function(c) c.floating = not c.floating end, {
      description = 'Toggle client float',
      group = 'Awesome'
   })
) --key_client

return {key_root,key_client}
