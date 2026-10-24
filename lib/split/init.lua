---Providers for mosaic tiling
local overdrip = require("lib.overdrip")
local allclients = require("lib.allclients")

local popup_registry = require("lib.popup_registry")
local signals = require("lib.signals")

local get_popup = popup_registry()

local is_spliting_provider = overdrip.provider(false)
local selected_index_provider = overdrip.provider(0)
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")

local m = {}

-- tiling clients other than the focused one
local candidates_provider = overdrip.provider(function(ref)
	local clients = ref.watch(allclients.provider)
	local focused = ref.watch(allclients.focused_provider)
	local ret = {}
	for _, c in ipairs(clients) do
		if c.valid and c ~= focused and not c.floating then
			table.insert(ret, c)
		end
	end
	return ret
end)

local selected_client_provider = overdrip.provider(function(ref)
	local candidates = ref.watch(candidates_provider)
	local i = ref.watch(selected_index_provider)
	local n = #candidates
	if n == 0 then
		return nil
	end
	return candidates[((i - 1) % n) + 1]
end)

local function make_button(text, on_click)
	return wibox.widget({
		widget = wibox.container.background,
		buttons = { awful.button({}, 1, on_click) },
		{
			widget = wibox.container.margin,
			margins = 10,
			{
				widget = wibox.widget.textbox,
				align = "center",
				text = text,
			},
		},
	})
end

function m.select_delta(delta)
	selected_index_provider.state = selected_index_provider.state + delta
end

function m.hide(s)
	get_popup(s or awful.screen.focused()).visible = false
end

function m.confirm(s)
	s = s or awful.screen.focused()
	local c = selected_client_provider.state
	m.hide(s)
	if not c then
		return
	end
	is_spliting_provider.state = true
	c:move_to_tag(s.selected_tag)
end

function m.widget(s)
	return overdrip.consumer_widget(function(ref)
		local candidates = ref.watch(candidates_provider)
		local close_button = make_button("Close", function()
			m.hide(s)
		end)

		if #candidates == 0 then
			return wibox.widget({
				layout = wibox.layout.fixed.vertical,
				{
					widget = wibox.widget.textbox,
					align = "center",
					text = "(no other clients)",
				},
				close_button,
			})
		end

		local c = ref.watch(selected_client_provider)
		local preview
		if c and c.content then
			preview = wibox.widget.imagebox(gears.surface(c.content))
		else
			preview = wibox.widget.textbox("No preview")
		end

		return wibox.widget({
			layout = wibox.layout.fixed.vertical,
			{
				widget = wibox.container.constraint,
				width = 640,
				height = 360,
				preview,
			},
			{
				layout = wibox.layout.flex.horizontal,
				make_button("Prev", function()
					m.select_delta(-1)
				end),
				make_button("Next", function()
					m.select_delta(1)
				end),
			},
			{
				layout = wibox.layout.flex.horizontal,
				close_button,
				make_button("Ok", function()
					m.confirm(s)
				end),
			},
		})
	end)
end

function m.show(s)
	s = s or awful.screen.focused()
	selected_index_provider.state = 1
	local popup = get_popup(s)
	popup.widget = m.widget(s)
	popup.visible = true
end

m.is_spliting_provider = is_spliting_provider
m.selected_index_provider = selected_index_provider

return m
