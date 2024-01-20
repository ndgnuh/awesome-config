--- This is the replica widget of wibox.container.background
--- Buttttt it allows setting hover background and on-press background
local container = require("wibox.container")
local gtable = require("gears.table")

-- Deep clone the background module
-- gtable.clone does not work for some reason
local bg = {}
local mt = gtable.clone(getmetatable(container.background))
gtable.crush(bg, container.background)

-- Patch the init function
mt.__call = function(...)
    -- lazy load beautiful
    local beautiful = require("beautiful")

    -- Super init
    local ret = container.background.mt.__call(...)

    -- Store Bg information
    ret.original_bg = ret.bg
    ret.hover_bg = ret.hover_bg or beautiful.hover_bg or beautiful.press_bg or ret.bg
    ret.press_bg = ret.press_bg or beautiful.press_bg or beautiful.hover_bg or ret.bg
    ret.hovering = false

    -- Handle background changing
    ret:connect_signal("mouse::enter", function(self) self.hovering = true end)
    ret:connect_signal("mouse::leave", function(self) self.hovering = false end)
    ret:connect_signal("mouse::enter", function(self) self.bg = self.hover_bg end)
    ret:connect_signal("mouse::leave", function(self) self.bg = self.original_bg end)
    ret:connect_signal("button::press", function(self) self.bg = self.press_bg end)
    ret:connect_signal("button::release", function(self)
        self.bg = self.hovering and self.hover_bg or self.original_bg
    end)
    return ret
end

--- set metatable
return setmetatable(bg, mt)
