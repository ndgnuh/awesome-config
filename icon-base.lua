local icon = {}
local ok, lgi = pcall(require, "lgi")
if not ok then
	print"lgi not found"
	return false
end
local cairo = lgi.cairo

icon.color = function(col)
    if col == nil then
        col = "#000000"
    elseif type(col) == "table" then
        col = col.color
    end
    return cairo.Pattern.create_rgba(color.parse_color(col))
end

icon.new = function(name)
	local img = cairo.ImageSurface(cairo.Format.ARGB32, 64, 64)
	local cr = cairo.Context(img)

	local ic = {
		name = name,
		surface = img,
		context = cr,
	}
	ic.save = function()
		ic.draw(cr, 64, 64)
		ic.surface:write_to_png(name .. ".png")
	end
	return ic
end

return icon
