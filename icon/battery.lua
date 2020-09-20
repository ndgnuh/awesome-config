local Icon = require"icon-base"
local max = math.max
local min = math.min

local color = Icon.color

local icon
for percent = 1, 100 do
	icon = Icon.new(string.format("battery-icon/battery-%03d", percent))
	icon.draw = function(cr, w, h)
		local pc = h / 100 * percent
		print(chop)
		cr:rectangle(w/4, h - pc, w/2, pc)
		cr:set_source(Icon.color("#ffffff"))
		cr:fill()
	end
	icon.save()
end
