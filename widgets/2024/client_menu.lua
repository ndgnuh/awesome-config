local awful = require("awful")
local gears = require("gears")
local W = require("wibox.widget")
local C = require("wibox.container")
local L = require("wibox.layout")

--- mechanism to control the popup
local mod = {}
mod.current_popup = nil

--- Create a item widget for the client menu
-- @arg c: The client
-- @arg text: The item text
-- @arg callback: Callback when clicked
local menu_item = function(c, text, callback)
	local bg = W { widget = C.background, forced_width = 200, }
	bg:connect_signal("mouse::enter", function() bg.bg = "#a9a9a9" end)
	bg:connect_signal("mouse::leave", function() bg.bg = nil end)

	local margin = W { widget = C.margin, left = 20, top = 10, right = 20, bottom = 10 }
	margin:connect_signal("mouse::enter", function() margin.left = 50 end)
	margin:connect_signal("mouse::leave", function() margin.left = 20 end)

	return {
		widget = bg,
		buttons = gears.table.join(
		-- use right click to perform actgion without closing the menu
			awful.button({}, 3, function()
				callback()
				_ = mod.current_popup and mod.current_popup.reload()
			end),
			-- use left click to perform action and close the menu
			awful.button({}, 1, function()
				callback()
				_ = mod.current_popup and mod.current_popup.close()
			end)
		),
		{
			widget = margin,
			{
				widget = W.textbox,
				text = text,
			}
		}
	}
end

local menu_spacer = function()
	return {
		widget = C.constraint,
		{
			forced_height = 30,
			widget = W.textbox,
			markup = "<span color='#555'>---------------------------------</span>",
			align = 'center',
		}
	}
end

local menu_widget = function(c)
	local lst = W {
		layout = L.fixed.vertical,
		(c.minimized and
			menu_item(c, "Un-minimize", function() c:emit_signal("request::activate", "key.unminimize", { raise = true }) end)
			or menu_item(c, "Minimize", function() c.minimized = true end)),
		menu_item(c, (c.maximized and "Un-maximize" or "Maximize"), function() c.maximized = not c.maximized end),
		menu_item(c, (c.floating and "Un-float" or "Float"), function() c.floating = not c.floating end),
		menu_item(c, (c.sticky and "Un-stick" or "Sticky"), function() c.sticky = not c.sticky end),
		menu_item(c, (c.ontop and "Disable always on-top" or "Always on-top"), function() c.ontop = not c.ontop end),
		menu_item(c, (c.fullscreen and "Exit fullscreen" or "Fullscreen"), function() c.fullscreen = not c.fullscreen end),
		menu_spacer(),
		menu_item(c, "Kill", function() c:kill() end),
		menu_item(c, "Cancel", function() mod.current_popup.close() end),
	}
	return lst
end

local menu_popup = function(c)
	local popup = awful.popup {
		ontop = true,
		visible = true,
		widget = menu_widget(c),
	}

	-- some actions
	popup.reload = function()
		popup.widget = menu_widget(c)
	end
	popup.close = function()
		mod.current_popup.visible = false
		mod.current_popup = nil
	end
	awful.placement.next_to_mouse(popup)
	return popup
end

local create = function(c)
	if mod.current_popup ~= nil then
		mod.current_popup.visible = false
		mod.current_popup = nil
	else
		mod.current_popup = menu_popup(c)
	end
end

mod.menu_widget = menu_widget
mod.create = create
return mod
