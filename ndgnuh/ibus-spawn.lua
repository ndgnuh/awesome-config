-- IBus module
-- This is a work aroudn for NixOS, LGI gets the
-- signal from IBus, but does not receive the engine's
-- information.
-- The workaround spawn `ibus engine` instead of
-- using information from GI signals.
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local ic = require("lib.icecream")
local resource = require("lib.resource")
local naughty = require("naughty")
local ibus = require("lib.ibus")

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

function m:update_engine(engine)
	local text_role = self.text_role

	-- engine name received
	if engine then
		local format = self.engine_formats[engine] or engine
		text_role:set_markup("<b>" .. format .. "</b>")
		return
	end

	-- engine can be nil, call ibus engine in that case
	awful.spawn.easy_async_with_shell("ibus engine", function(stdout, stderr)
		local engine = gears.string.split(stdout, "\n")[1]
		if stderr ~= "" then
			naughty.notification({
				title = "IBus",
				message = "Error: " .. tostring(stderr),
			})
			text_role:set_markup("<b>!!</b>")
		else
			local format = self.engine_formats[engine] or "??"
			text_role:set_markup("<b>" .. format .. "</b>")
		end
	end)
end

local function new()
	local ret = wibox.widget({
		widget = wibox.container.background,
		bg = resource.rgbf(0.6, 0.4, 0.4),
		forced_width = beautiful.wibar_height,
		forced_height = beautiful.wibar_width,
		shape = gears.shape.rounded_rect,
		{
			widget = wibox.container.place,
			{
				widget = wibox.widget.textbox,
				align = "center",
				vertical_align = "center",
				id = "text_role",
			},
		},
	})
	ret.text_role = ret:get_children_by_id("text_role")[1]

	gears.table.crush(ret, m, true)

	-- ibus init + watch for changes
	-- local bus = IBus.Bus()
	-- bus:set_watch_ibus_signal(true)
	-- bus:set_watch_dbus_signal(true)
	--
	-- bus:set_global_engine("xkb::us::eng")

	ibus:connect_signal("ibus:global-engine-changed", function(self, engine_name)
		ret:update_engine(engine_name)
	end)
	-- function bus:on_connected()
	-- 	-- 	naughty.notification({
	-- 	-- 		title = "IBus",
	-- 	-- 		message = "Connected",
	-- 	-- 		preset = "debug",
	-- 	-- 	})
	-- 	local engine = self:get_global_engine()
	-- 	ret:update_engine(engine.name)
	-- 	-- 	naughty.notification({
	-- 	-- 		title = "IBus",
	-- 	-- 		message = "Engine: " .. gears.table.dump_return(engine),
	-- 	-- 		preset = "debug",
	-- 	-- 	})
	-- 	-- 	ic(engine)
	-- end
	--
	-- function bus:on_global_engine_changed(e)
	-- 	ret:update_engine(e)
	-- end

	return ret
end

function m._mt:__call()
	return new()
end

return setmetatable(m, m._mt)
