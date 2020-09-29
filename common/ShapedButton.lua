local Module = {}

local tint = function(c, level)
  local ret, channel, cmatch = "#", 1
  if #c > 5 then
    cmatch = c:gmatch("[A-Fa-f0-9][A-Fa-f0-9]")
  else
    cmatch = c:gmatch("[A-Fa-f0-9]")
  end

  local cval = cmatch()
  while cval do
    if channel < 4 then
      cval = cval + level
    end
    if cval > 255 then
      cval = 255
    end
    ret = ret .. tostring(cval)
    channel = channel + 1
    cval = cmatch()
  end
  return ret
end

Module.generic_button = function(self, arg)
  assert(type(arg) ~= "table")
  local wibox = require"wibox"

  local btn = wibox.widget {
    widget = wibox.container.background,
    dispatch = self.dispatch[action],
    wibox.widget.textbox()
  }

  btn:connect_signal("button::press", function()
  end)


  if arg.onclick then
    btn:connect_signal("button::press", arg.onclick)
  end

  if arg.onhover then
    btn:connect_signal("mouse::enter", arg.onhover)
  end

  if arg.onhover then
    btn:connect_signal("mouse::leave", arg.onhover)
  end

  return btn
end

return Module
