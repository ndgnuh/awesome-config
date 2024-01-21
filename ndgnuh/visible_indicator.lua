--- A wibar item to indicate if a tag is selected or not
-- This is just a wrapper of image box with icons
local awful = require("awful")
local imagebox = require("wibox.widget.imagebox")
local lib = require("lib")
local beautiful = require("beautiful")
local capi = { screen = screen }
local visibile_indicator = { mt = {} }

--- Create a visible indicator
-- All arguments are the same as those of imagebox.
local new = function(...)
    local widget = imagebox(...)

    --- Update based on the number of tags selected
    local update = function(updated_screen)
        if updated_screen.selected_tag == nil then
            widget:set_image(lib.icon("./assets/icons/visibility_off.svg", beautiful.fg_focus))
        else
            -- widget:set_image(lib.icon("./assets/icons/visibility.svg", beautiful.fg_focus))
            widget:set_image(nil)
        end
    end

    -- callback + first update
    capi.screen.connect_signal("tag::history::update", update)
    update(awful.screen.focused())

    return widget
end

--- Wrap new function
-- All arguments are the same as those of imagebox.
function visibile_indicator.mt:__call(...)
    return new(...)
end

return setmetatable(visibile_indicator, visibile_indicator.mt)
