local awful = require("awful")
local client = client
local tag = tag
local db = require("Debug")

return function(arg)
  local callback = arg.callback
  local s = arg.screen or arg.object.screen or awful.screen.focused()

  local real_callback = function()
    local isempty = #(s:get_clients()) == 0
    return callback(isempty)
  end
  callback(true)
  client.connect_signal("manage", real_callback)
  client.connect_signal("property::minimized", real_callback)
  -- this signal doesn't work on tag.viewnone()
  -- s:connect_signal("tag::history::update", real_callback)
  tag.connect_signal("property::selected", real_callback)
end
