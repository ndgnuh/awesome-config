local wibox = require("wibox")
local IBus = require("IBus")

local widget = wibox.widget
  { widget = wibox.widget.textbox
  , text = lang
  }

do
  local engine = IBus:get()
  local lang
  if engine then
    lang = engine.language
  else
    lang = "?"
  end
end

local update = function(engine)
  widget.text = engine.language
end

IBus:watch(update)

return widget
