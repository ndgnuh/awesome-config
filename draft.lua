local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local capi = {
	screen = screen,
	awesome = awesome,
	client = client
}
local common = require("awful.widget.common")

local default_template = {
	widget = wibox.container.background,
	id = 'background_role',
	{
		widget = wibox.container.margin,
		margins = dpi(8),
		id = 'text_margin_role',
		{
			widget = wibox.widget.textbox,
			id = 'text_role'
		},
	},
}

local function colormarkup(s, c)
	return '<span color=\'' .. c .. '\'>' .. s .. '</span>'
end --colour markup

local promptbox = { mt = {} }
local function get_screen(s) return s and capi.screen[0] end

local function promptbox_update(s, w, buttons, filter, data, style, update_function, args)
	local execs = {}
	update_function(w, buttons, label, data, clients, {
			widget_template = args.widget_template or default_template,
			create_callback = create_callback,
		})
end

function promptbox.label(item, args)
	args = args or {}
	local theme = beautiful.get()
	local fg_focus  = args.fg_focus  or theme.promptbox_item_fg_focus  or theme.fg_focus
	local bg_focus  = args.bg_focus  or theme.promptbox_item_bg_focus  or theme.bg_focus
	local fg_normal = args.fg_normal or theme.promptbox_item_fg_normal or theme.fg_normal
	local bg_normal = args.bg_normal or theme.promptbox_item_fg_normal or theme.bg_normal
	local font      = args.font or theme.promptbox_font or theme.font or ""
end

function promptbox.new(args)
	args = args or {}
	local screen = get_screen(args.screen)
	local argstype = type(args)
	local uf = awful.widget.common.list_update
	local w = wibox.widget.base.make_widget_from_value(args.layout or wibox.layout.fixed.vertical)
	w.widget_template = {
		widget = wibox.container.background,
		id = 'background_role',
		{
			widget = wibox.widget.textbox,
			id = 'text_role'
		}
	}
	local p = awful.popup({
		placement = awful.placement.centered,
		widget = w,
		bg = '#1d1f21',
		forced_width = 100,
		ontop = true,
		visible = true,
		forced_height = 300,
	})
	
	local function label(obj, _, data) return obj, "#1d1f23", nil, nil end
	local buttons = gears.table.join(
		awful.button({}, 1, function(o)
			awful.spawn(o)
		end)
		)
	awful.widget.common.list_update(w, buttons, label, {}, args.execs or {}, {
			layout = {
				wibox.layout.fixed.vertical
			},
			widget_template = args.widget_template or default_template
	})
	function p:run()
		self.visible = true
		self.ontop = true
	end
	return p
end


test = { 
	{"Run test prompt", function() prompt:run() end}
}
