local wibox = re"wibox"
local shape = re"gears.shape"
local surface = re"gears.surface"

local module = {}
local cachedSurface = {}

local fit = function(self, ctx, w, h)
	local s = math.min(w, h)
	return w, h
end

local set_client = function(self, c)
    self._private.client[1] = c
    self:emit_signal("widget::redraw_needed")
end

local draw = function(self, content, cr, width, height)
	local c = self._private.client[1]
	local s, geo = surface(c.content), c:geometry()
	if c.minimized then
		s = cachedSurface[c]
	else
		cachedSurface[c] = s
	end
	-- local scale = math.max(width/geo.width, height/geo.height)
	local scalex, scaley = width/geo.width, height/geo.height
	local scale = math.max(scalex, scaley)
	local w, h = geo.width*scalex, geo.height*scaley
	local dx, dy = (width-w)/2, (height-h)/2
	cr:translate(dx, dy)
	shape.rounded_rect(cr, w, h)
	cr:clip()
	local sw, sh = surface.get_size(s)
	cr:scale(width / sw, height / sh)
	cr:set_source_surface(s)
	cr:paint()
end

local geo = function(self)
    local c = self._private.client[1]
	 if c then
		 return c:geometry()
	 end
end


local function new(c)
    local ret = wibox.widget.base.make_widget(nil, nil, {
        enable_properties = true,
    })

    rawset(ret, "fit", fit)
    rawset(ret, "draw", draw)
    rawset(ret, "set_client", set_client)
    rawset(ret, "geo", geo)
    ret._private.client = setmetatable({c}, {__mode="v"})
    return ret
end

return setmetatable(module, {__call=function(_,...) return new(...) end})
