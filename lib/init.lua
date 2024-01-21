-- this is the index module for other modules
-- and to include small functions
local gfs = require("gears.filesystem")
local gcolor = require("gears.color")
local m = {
    icecream = require("lib.icecream"),
    rrequire = require("lib.rrequire"),
    widgets = require("lib.widgets"),
    workflow = require("lib.workflow"),
}


--- Get resource from configuration directory
--- @param path string: resource path relative to the configuration directory
--- @return string: absolute path to resource
m.resource = function(path)
    return gfs.get_configuration_dir() .. path
end

--- Get icon resource and recolor if needed
--- @param path string: icon path relative to configuration directory
--- @param color string: hex color string, if is nil, the icon won't be recolored
--- @return cairo.ImageSurface: recolored icon
m.icon = function(path, color)
    local ic = resource(path)
    if color then
        return gcolor.recolor_image(ic, color)
    else
        return ic
    end
end

--- Create text mark up with color
--- @param text string: the text to be formatted
--- @param color string: the hex color string
m.text_color = function(text, color)
    return [[<span color="]] .. color .. [[">]] .. text .. [[</span>]]
end

return m
