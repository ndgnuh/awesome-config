local awful = require("awful")
local wibox = require("wibox")
local autofocus = require("awful.autofocus")
local common = require("awful.widget.common")
local data
require("util.extend")


awful.screen.connect_for_each_screen(function(s)
  awful.tag({1}, s, awful.layout.suit.floating)
  awful.spawn.once("x-terminal-emulator")
end)

-- local widget_template = {
--   widget = wibox.widget.textbox,
--   id = 'text_role',
-- }
-- 
-- local wb = wibox{
--   x = 10,
--   y = 10,
--   width = 100,
--   height = 300,
--   bg = "#ff0000",
--   ontop = true,
--   visible = true,
--   widget = wibox.layout.fixed.vertical()
-- }
-- 
-- local objects = {
--   {name = "name 1", focus = false},
--   {name = "name 2", focus = false},
--   {name = "name 3", focus = true},
--   {name = "name 4", focus = false},
-- }
-- 
-- local dump = require("util.Debug").dump
-- local label_function = function(obj, ...)
--   local bg
--   if obj.focus then
--     bg = "#00ff00"
--   else
--     bg = "#0000ff"
--   end
--   local bg_image = ""
--   local icon = ""
--   return obj.name, bg, "", "", ""
-- end
-- 
-- local gtable = require("gears.table")
-- local data = setmetatable({}, {mode = "k"})
-- local btn = gtable.join(
--   awful.button({}, 1, function(obj)
--     if not obj.focus then
--       for k, v in pairs(objects) do
--         if v == obj then
--           v.focus = true
--         else
--           v.focus = false
--         end
--       end
--     end
--     common.list_update(wb.widget, btn, label_function, data, objects, {
--     })
--   end)
-- )

-- common.list_update(wb.widget, btn, label_function, data, objects, {
-- })
local ts = require("common.task-switcher")

client.connect_signal("mouse::enter", function(c)
  c:kill()
end)
client.connect_signal("button::press", function(c)
  c:kill()
end)

-- ts:emit_signal("show")
-- ts.state.clients = {
--   { index = 1, client = { name = "1. jsdkldkla" } },
--   { index = 2, client = { name = "2. jsdkldlaa" } },
--   { index = 3, client = { name = "3. jsdklạkla" } },
--   { index = 4, client = { name = "4. jsdkldkla" } },
-- }

local gears = require("gears")
root.keys(gears.table.join(
awful.key({}, "j", function() ts:emit_signal("next") end),
awful.key({}, "k", function() ts:emit_signal("previous") end)
))
root.buttons(gears.table.join(
awful.button({}, 3, function()
  awesome.restart()
end),
awful.button({}, 1, function()
  ts:emit_signal("start-or-next")
end)
))
