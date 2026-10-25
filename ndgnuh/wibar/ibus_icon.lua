-- IBus engine indicator, shows the current global engine from
-- `providers.global_ibus_engine`.
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local resource = require("lib.resource")
local overdrip = require("lib.overdrip")
local engine_provider = require("providers.global_ibus_engine").global_ibus_engine_provider

local m = {
	-- the string to display inside the icon
	engine_formats = {
		["xkb:us::eng"] = "EN",
		["Bamboo"] = "VI",
		["anthy"] = "JP",
		["kkc"] = "JP",
	},
	_mt = {},
}

local function new()
	return wibox.widget({
		widget = wibox.container.background,
		bg = resource.rgbf(0.6, 0.4, 0.4),
		forced_width = beautiful.wibar_height,
		forced_height = beautiful.wibar_width,
		shape = gears.shape.rounded_rect,
		overdrip.consumer_widget(function(ref)
			local engine = ref.watch(engine_provider)
			-- engine is nil until ibus-daemon reports one
			local format = engine and (m.engine_formats[engine] or engine) or "??"
			return wibox.widget({
				widget = wibox.widget.textbox,
				align = "center",
				valign = "center",
				markup = "<b>" .. format .. "</b>",
			})
		end),
	})
end

function m._mt:__call()
	return new()
end

return setmetatable(m, m._mt)
