local wibox = require"wibox"
local beautiful = require"beautiful"
local gears = require"gears"

local unpack = unpack or table.unpack

-- color definition{{{
local color_normal =
  beautiful.hoverbox_normal or
  gears.color.transparent
local color_hover =
  beautiful.hoverbox_focus or
  beautiful.bg_focus or
  gears.color.transparent
local shape = beautiful.hoverbox_shape
--}}}

local hoverbox = function(w, shape, callback)
  local wrapper = wibox.container.background(w, _, shape)
  wrapper:connect_signal("mouse::enter", function(self)
    self.bg = color_hover
    if callback and type(callback) == "function" then
      callback(self)
    end
  end)
  wrapper:connect_signal("mouse::leave", function(self)
    self.bg = color_normal
  end)
  return wrapper
end

return hoverbox
