local consts = require.rel("consts")
local popup = require.rel("popup")
local bamboo_menu = require.rel("bamboo_menu")
local property_menu = require.rel("property_menu")

local m = {
	consts = consts,
	_popup = popup,
}

m.show_bamboo_menu = bamboo_menu.show
m.hide_bamboo_menu = bamboo_menu.hide
m.show_property_menu = property_menu.show
m.hide_property_menu = property_menu.hide

return m
