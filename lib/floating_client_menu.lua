local gears = require("gears")
local awful = require("awful")

local resource = require("lib.resource")
local ic = require("lib.icecream")
local bamboo_mode_select = require("ndgnuh.bamboo_mode_select")

local icon_roots = "./assets/icons/"
local check_icon = resource.icon(icon_roots .. "checkbox_checked.png")
local uncheck_icon = resource.icon(icon_roots .. "checkbox_unchecked.png")

local properties = {
	{ name = "ontop", label = "On top", label_alt = "Disable on-top" },
	{ name = "sticky", label = "Sticky", label_alt = "Disable sticky" },
	{ name = "floating", label = "Floating", label_alt = "Disable floating" },
	{ name = "maximized", label = "Maximize", label_alt = "Un-maximize" },
	{ name = "minimized", label = "Minimize", label_alt = "Un-minimize" },
	{ name = "fullscreen", label = "Fullscreen", label_alt = "Exit fullscreen" },
}

local dummy_command = function() end
local items = gears.table.map(function(property)
	local label = property.label
	return { label, dummy_command, uncheck_icon }
end, properties)
items[#items + 1] = { "Input mode", dummy_command }
items[#items + 1] = { "Cancel", dummy_command }

local menu = awful.menu({ items = items })

local update_and_show
update_and_show = function(c, save_coords, save_sel)
	c = c or client.focus

	-- menu.layout = nil
	-- menu.items = nil
	-- menu.wibox._signals = {}

	-- Store mouse position to re-open the menu
	save_coords = save_coords or mouse.coords()

	for i, property in ipairs(properties) do
		local item = menu.items[i]
		-- if i == 1 then
		-- 	ic(item)
		-- end

		-- Bind function to focused client
		local key = property.name
		item.cmd = function()
			c[key] = not c[key]
			gears.timer.delayed_call(function()
				update_and_show(c, save_coords)
			end)
		end

		-- Bind label to focused client
		-- Icon or text, choose one, both is confusing ux
		-- item.label.text = c[key] and property.label_alt or property.label

		-- Bind icon to focused client
		item.icon.image = c[key] and check_icon or uncheck_icon
	end

	-- Bind input mode menu to focused client
	menu.items[#properties + 1].cmd = function()
		bamboo_mode_select(c)
		awful.spawn("ibus restart")
	end

	menu:update()
	menu:show()
	if save_coords then
		gears.timer.delayed_call(function()
			menu.wibox.x = save_coords.x
			menu.wibox.y = save_coords.y
		end)
	end

	save_sel = 1 -- TBA
	gears.timer.delayed_call(function()
		menu:item_enter(save_sel)
	end)
end

return update_and_show
