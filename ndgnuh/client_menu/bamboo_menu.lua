local popup = require.rel("popup")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local client_providers = require("providers.clients")
local bamboo_cli = require("lib.bamboo_cli")
local overdrip = require("lib.overdrip")
local widgets = require("lib.widgets")
local icons = require("assets.icons")

-- Local states
local m = {}
local bamboo_notification -- Persistent notification
local bamboo_grabber -- late binding for keygrabber

local BAMBOO_MODE_PREEDIT = "preedit"
local BAMBOO_MODE_SURROUNDING_TEXT = "surrounding-text"
local BAMBOO_MODE_FORWARD_KEY_1 = "forward-key-1"
local BAMBOO_MODE_FORWARD_KEY_2 = "forward-key-2"
local BAMBOO_MODE_FORWARD_AS_COMMIT = "forward-as-commit"
local BAMBOO_MODE_XTEST = "xtest"
local BAMBOO_MODE_EXCLUDE = "exclude"

-- Ordered so that the position matches bamboo-cli's mode index
local bamboo_modes = {
	BAMBOO_MODE_PREEDIT,
	BAMBOO_MODE_SURROUNDING_TEXT,
	BAMBOO_MODE_FORWARD_KEY_1,
	BAMBOO_MODE_FORWARD_KEY_2,
	BAMBOO_MODE_FORWARD_AS_COMMIT,
	BAMBOO_MODE_XTEST,
	BAMBOO_MODE_EXCLUDE,
}

local bamboo_modes_to_descriptions = {
	[BAMBOO_MODE_PREEDIT] = "Cấu hình mặc định (Pre-edit)",
	[BAMBOO_MODE_SURROUNDING_TEXT] = "Sửa lỗi gạch chân (Surrounding Text)",
	[BAMBOO_MODE_FORWARD_KEY_1] = "Sửa lỗi gạch chân (ForwardKeyEvent I)",
	[BAMBOO_MODE_FORWARD_KEY_2] = "Sửa lỗi gạch chân (ForwardKeyEvent II)",
	[BAMBOO_MODE_FORWARD_AS_COMMIT] = "Sửa lỗi gạch chân (Forward as commit)",
	[BAMBOO_MODE_XTEST] = "Sửa lỗi gạch chân (XTestFakeKeyEvent)",
	[BAMBOO_MODE_EXCLUDE] = "Thêm vào danh sách loại trừ",
}

local action_notify = function(message)
	if bamboo_notification then
		bamboo_notification:dismiss()
	end
	bamboo_notification = naughty.notification({
		title = "<b>Bamboo Menu</b>",
		message = message,
	})
end

local action_quit = function()
	if bamboo_grabber then
		bamboo_grabber:stop()
		bamboo_grabber = nil
	end
	popup.hide(popup.get_input_mode_popup())
end

local action_set_mode = function(mode)
	return function()
		local c = client.focus
		local wmclass = c and c.class
		if not wmclass then
			return action_notify("Không có cửa sổ nào đang focus")
		end

		bamboo_cli.mode.set(wmclass, mode, function(ok, err)
			action_quit()
			if not ok then
				return action_notify("Lỗi: " .. tostring(err))
			end
			action_notify(
				[[Đặt chế độ của "]]
					.. wmclass
					.. [[" thành "]]
					.. bamboo_modes_to_descriptions[mode]
					.. [[".]]
					.. "\n"
					.. [[Khởi động lại bộ gõ để có hiệu lực.]]
			)
		end)
	end
end

local bamboo_hotkeys = {
	["q"] = action_quit,
	["Escape"] = action_quit,
	["Return"] = action_quit,
	["space"] = action_quit,
}
for index, mode in ipairs(bamboo_modes) do
	bamboo_hotkeys[tostring(index)] = action_set_mode(mode)
end

--- focused wmclass widget
local focused_wmclass = overdrip.consumer_widget(function(ref)
	local c = ref:watch(client_providers.focused_provider)
	local markup
	if c then
		markup = "<b>" .. tostring(c.class) .. "</b>"
	else
		markup = "(No focused window)"
	end

	return wibox.widget({
		widget = wibox.container.margin,
		margins = 4,
		{
			widget = wibox.widget.textbox,
			markup = markup,
		},
	})
end)

local function build_tile(icon, hotkey, title, action)
	local place = function(w)
		return {
			widget = wibox.container.place,
			forced_height = 32,
			w,
		}
	end

	return {
		widget = widgets.InkWell,
		buttons = {
			awful.button({}, 1, action),
		},
		{
			widget = wibox.container.margin,
			margins = 8,
			{
				widget = wibox.layout.fixed.horizontal,
				spacing = 28,
				place(wibox.widget.textbox(hotkey)),
				place(wibox.widget.imagebox(icon)),
				place(wibox.widget.textbox(title)),
			},
		},
	}
end

local function build_bamboo_tile(index, mode, selected)
	local icon = selected and icons.checkbox_checked or icons.checkbox_unchecked
	return build_tile(icon, tostring(index), bamboo_modes_to_descriptions[mode], action_set_mode(mode))
end

local function build_bamboo_mode_widgets()
	-- Columns instead of a grid: somewm's grid sizes each row independently,
	-- so non-homogeneous columns do not align across rows
	local layout = wibox.widget({
		layout = wibox.layout.fixed.vertical,
		focused_wmclass,
	})

	bamboo_cli.mode.get(function(selected_mode)
		for index, mode in ipairs(bamboo_modes) do
			layout:add(build_bamboo_tile(index, mode, selected_mode == mode))
		end
		layout:add(build_tile(icons.logout, "q", "Thoát", action_quit))
	end)

	return layout
end

m.show = function()
	-- Set up bamboo widget
	local p = popup.get_input_mode_popup()
	p.widget = build_bamboo_mode_widgets()

	if bamboo_grabber then
		bamboo_grabber:stop()
	end
	bamboo_grabber = awful.keygrabber({
		autostart = true,
		keypressed_callback = function(_, _, key)
			local action = bamboo_hotkeys[key]
			if action then
				action()
			end
		end,
	})

	popup.show(p)
end

m.hide = action_quit

return m
