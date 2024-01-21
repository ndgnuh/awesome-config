local module = {}

local lgi = require("lgi")
local cairo = lgi.cairo
local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, 100, 100)
local cr = cairo.Context(surface)

module.cairo = function()
end

return module
