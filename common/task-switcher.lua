local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local module = { proto = {} }

module.proto.wibox = awful.popup {
  placement = awful.placement.centered,
  widget = wibox.widget{
    layout = wibox.layout.fixed.vertical
  }
}

module.new = function(arg)
  local ret = gtable.crush({}, module.proto)
  if arg.layout then
    ret.wibox.widget = wibox.widget(layout)
  end
end

return module
