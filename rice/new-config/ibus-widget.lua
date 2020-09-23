local IBus = require"IBus"
local awful = require"awful"
local wibox = require"wibox"
local gears = require"gears"
local beautiful = require"beautiful"
local hoverbox = require"hoverbox"

-- ibus menu{{{
local menu = awful.menu {
  items = {
    {"Start", "ibus-daemon -rdxs"},
    {"Restart", "ibus restart"},
    {"Preference", "ibus-setup"},
    {"Quit", "ibus exit"},
    {"Cancel", ""}
  }
}
--}}}

-- buttons{{{
local widget_buttons = gears.table.join(
  IBus.button({}, 1, {"xkb:us::eng", "Bamboo"}),
  awful.button({}, 3, function() menu:show() end)
  )
--}}}

-- the widget{{{
local markup = "<b>%s</b>"
local widget = wibox.widget {
  widget = wibox.widget.textbox,
  markup = "?"
}
--}}}

-- callback to update {{{
local callback = function (engine)
  widget.markup = markup:format(engine.language)
end
callback(IBus:get())
IBus:watch(callback)
--}}}

local bounding = wibox.widget {
  widget = wibox.container.place,
  forced_width = beautiful.wibar_height,
  forced_height = beautiful.wibar_width,
  buttons = widget_buttons,
  widget,
}

return hoverbox(bounding)
