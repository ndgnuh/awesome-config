local wibox = require("wibox")
local gears = require("gears")

local ListTile = {}

function ListTile:set_leading(image)
	local w = self._private.first
	w.image = image
end

function ListTile:set_title(text)
	local w = self._private.title
	w:set_markup(text)
end

function ListTile:set_subtitle(text)
	local w = self._private.subtitle
	w:set_markup("<span color='#CCC' size='small'>" .. text .. "</span>")
end

function ListTile:set_trailing(image)
	local w = self._private.third
	w.image = image
end

function ListTile.new(args)
	args = args or {}

	local title = wibox.widget({
		widget = wibox.widget.textbox,
		valign = "center",
	})
	local subtitle = wibox.widget({
		widget = wibox.widget.textbox,
		valign = "center",
	})

	local proxy = wibox.widget({
		widget = wibox.layout.align.horizontal,
		{
			widget = wibox.widget.imagebox,
			valign = "center",
			halign = "center",
			forced_width = 32,
			forced_height = 32,
		},
		{
			widget = wibox.container.margin,
			left = 8,
			right = 8,
			{
				widget = wibox.layout.align.vertical,
				nil,
				title,
				subtitle,
			},
		},
		{
			widget = wibox.widget.imagebox,
			valign = "center",
			halign = "center",
		},
	})
	local ret = wibox.widget.base.make_widget(
		-- format comment
		proxy,
		"lib.widget.ListTile",
		{ enable_properties = true }
	)
	gears.table.crush(ret, ListTile, true)

	ret._private.first = proxy.first
	ret._private.title = args.title or title
	ret._private.subtitle = args.subtitle or subtitle
	ret._private.third = proxy.third

	return ret
end

ListTile = setmetatable(ListTile, {
	__call = function(self, args)
		return ListTile.new(args)
	end,
})

return ListTile
