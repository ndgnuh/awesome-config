local consts = require.rel("consts")
local popup = require.rel("popup")
local wibox = require("wibox")
local gears = require("gears")
local widgets = require("lib.widgets")
local bamboo_cli = require("lib.bamboo_cli")
local awful = require("awful")
local icons = require("assets.icons")
local naughty = require("naughty")

local m = {
	consts = consts,
	_popup = popup,
}

local bamboo_menu_timer -- late binding
local bamboo_notification -- late binding

-- TODO: add docs
local function build_bamboo_tile(mode, selected)
	local leading
	if selected then
		leading = wibox.widget.imagebox(icons.checkbox_checked)
	else
		leading = wibox.widget.imagebox(icons.checkbox_unchecked)
	end

	local place = function(w)
		return {
			widget = wibox.container.place,
			forced_height = 32,
			w,
		}
	end

	local index = wibox.widget.textbox(tostring(mode.index))
	local title = wibox.widget.textbox(tostring(mode.display_name))

	local app_id = client.focus.class

	return {
		widget = widgets.InkWell,
		buttons = {
			awful.button({}, 1, function()
				bamboo_cli.mode.set_focused(mode.name, function()
					local p = popup.get_input_mode_popup()
					popup.hide(p)
					if bamboo_notification then
						bamboo_notification:dismiss()
					end
					bamboo_notification = naughty.notification({
						title = "<b>Bamboo CLI</b>",
						message = [[Đặt chế độ của "]]
							.. app_id
							.. [[" thành "]]
							.. mode.display_name
							.. [[".]]
							.. "\n"
							.. [[Khởi động lại bộ gõ để có hiệu lực.]],
					})
				end)
			end),
		},
		{
			widget = wibox.container.margin,
			margins = 8,
			{
				widget = wibox.layout.fixed.horizontal,
				spacing = 12,
				place(leading),
				place(index),
				place(title),
			},
		},
	}
end

local function build_bamboo_mode_widgets()
	-- Columns instead of a grid: somewm's grid sizes each row independently,
	-- so non-homogeneous columns do not align across rows
	local layout = wibox.widget({
		layout = wibox.layout.fixed.vertical,
	})

	bamboo_cli.mode.get(function(selected_mode)
		bamboo_cli.mode.list(function(modes)
			for _, mode in ipairs(modes) do
				local selected = selected_mode == mode.name
				local tile = build_bamboo_tile(mode, selected)
				layout:add(tile)
			end
		end)
	end)

	return layout
end

m.show_bamboo_menu = function()
	-- Set up bamboo widget
	local p = popup.get_input_mode_popup()
	p.widget = build_bamboo_mode_widgets()

	popup.show(p)
end

return m
