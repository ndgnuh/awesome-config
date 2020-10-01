local cairo = require("lgi").cairo

local Draw = {}

function Draw.draw(shape, w, h)
	w = w or 64
	h = h or w or 64
	local img = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
	local cr = cairo.Context(img)
	shape(cr, w, h)
	return img
end

function Draw.mkgrid(cr, w, h, nw, nh)
   nh = nh or nw
   local dw = w / nw
   local dh = h / nh
   local function lt(x, y) cr:line_to(x*dw, y*dh) end
   local function mt(x, y) cr:move_to(x*dw, y*dh) end
   return mt, lt
end

return Draw
