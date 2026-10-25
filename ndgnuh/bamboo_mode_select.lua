--- Menu to select the ibus-bamboo typing mode of a client.
---
--- Usage:
---   local bamboo_mode_select = require("ndgnuh.bamboo_mode_select")
---   bamboo_mode_select(c) -- defaults to the focused client
local awful = require("awful")
local bamboo = require("lib.bamboo_cli")

local menu

local function show(c, modes, current)
	--- bamboo-cli keys apps by wayland app id or X11 wm_class
	local app_id = c.class
	local items = {}
	for _, mode in ipairs(modes) do
		local label = (mode.name == current and "✓ " or "   ") .. mode.display_name
		items[#items + 1] = {
			label,
			function()
				bamboo.mode.set(app_id, mode.name)
			end,
		}
	end
	items[#items + 1] = { "Cancel", function() end }

	if menu then
		menu:hide()
	end
	menu = awful.menu({ items = items })
	menu:show()
end

return function(c)
	c = c or client.focus
	if not c or not c.class then
		return
	end

	bamboo.mode.list(function(modes)
		if not modes then
			return
		end
		--- `mode get` only reports the focused client
		if c ~= client.focus then
			show(c, modes)
			return
		end
		bamboo.mode.get(function(current)
			show(c, modes, current)
		end)
	end)
end
