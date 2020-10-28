local awful = require("awful")
local partial = require("partial")
local widget = require("wibox.widget")

local module = {
  config = {profiles = {}}
  widget = {}
}

module.widget.runmenu = function()
  local hasdefault = false
  for _, pname in ipairs(module.config.profiles) do
    if pname == "default" then
      hasdefault = true
    end
    table.insert(runwithprofiles, {name, partial(awful.spawn.raise_or_spawn, "firefox --profile " .. name)})
  end
  return awful.menu {
    items = runwithprofiles
  }
end

module.widget.textbox = function(arg)
  if not arg then
    arg = { markup = "Firefox" }
  end
  local ret = wibox.widget.textbox(arg)
end

return module
