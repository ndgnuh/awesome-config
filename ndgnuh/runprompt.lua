local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local unpack = table.unpack or unpack
local survival = require("lib.survival")
local lgi = require("lgi")
local ic = require("lib.icecream")
local resource = require("lib.resource")
local find_executable = require("lib.find_executable")

local selected_color = resource.rgbf(0.3, 0.3, 0.32)

-- arg is just a name
local ctx = survival.context("ndgnuh-prompt")
local m = {
	widgets = {},
	commands = {},
	matched_commands = {},
	initialized = false,
	selected = 1,
	page = 1,
	per_page = 12,
	keyword = "",
}

local function ls(dirpath)
	local stdout = io.popen("ls '" .. dirpath .. "'"):read("*a")
	local cmds = gears.string.split(stdout, "\n")
	return cmds
end

-- search for commands matching keywords
m.search = function(keyword)
	local results = {}
	local results_2 = {}
	local lkeyword = keyword:lower()
	local n = #keyword

	for name, _ in pairs(m.commands) do
		local lcmd = name:lower()

		-- starts with -> best match
		-- just contains -> secondary match
		-- fuzzy matching is too heavy
		if lcmd:sub(1, n) == lkeyword then
			table.insert(results, name)
		elseif lcmd:match(lkeyword) then
			table.insert(results_2, name)
		end
	end

	-- prevents index starting from 2 when results is empty
	if #results == 0 then
		return results_2
	else
		return gears.table.join(results, results_2)
	end
end

m.init = function()
	if m.initialized then
		return
	end

	local theme = beautiful
	local gutter = theme.gutter or 16

	-- Widgets
	-- =======

	-- Prompter
	-- --------
	m.widgets.prompt_textbox = wibox.widget.textbox()

	-- Commands
	-- --------

	m.widgets.commands = {}
	for i = 1, m.per_page do
		local cmd_widget = wibox.widget.textbox("Command " .. tostring(i))
		table.insert(m.widgets.commands, cmd_widget)
	end

	-- the command backgrounds & layouts
	m.widgets.command_backgrounds = gears.table.map(function(w)
		return wibox.widget({
			widget = wibox.container.background,
			bg = gears.color.transparent,
			w,
		})
	end, m.widgets.commands)

	-- reload button: reload the command lists
	local reload_text = "reload"
	m.widgets.reload_button = wibox.widget.textbox()
	m.widgets.reload_button:set_markup(reload_text)
	m.widgets.reload_button:connect_signal("button::press", function()
		m.reload_path_commands()
	end)
	m.widgets.reload_button:connect_signal("mouse::enter", function()
		m.widgets.reload_button:set_markup(TextColor(reload_text, theme.primary))
	end)
	m.widgets.reload_button:connect_signal("mouse::leave", function()
		m.widgets.reload_button:set_markup(reload_text)
	end)

	-- The main widget
	-- ---------------
	m.widgets.main = wibox.widget({
		widget = wibox.container.background,
		bg = resource.rgbf(0.2, 0.2, 0.22),
		forced_width = 500,
		{
			widget = wibox.container.margin,
			margins = gutter,
			{
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.align.horizontal,
					m.widgets.prompt_textbox,
					nil,
					m.widgets.reload_button,
				},
				{
					widget = wibox.container.margin,
					bottom = gutter / 2,
					top = gutter / 2,
					{
						layout = wibox.container.background,
						bg = theme.primary,
						forced_height = 2,
					},
				},
				{
					layout = wibox.layout.fixed.vertical,
					unpack(gears.table.map(function(w)
						return wibox.widget({
							widget = wibox.container.margin,
							top = gutter / 4,
							bottom = gutter / 4,
							w,
						})
					end, m.widgets.command_backgrounds)),
				},
			},
		},
	})

	m.widgets.waiting = {
		widget = wibox.container.background,
		wibox.widget.textbox("Loading..."),
	}

	m.wibox = awful.popup({
		placement = awful.placement.centered,
		widget = m.widgets.main,
		border_width = 2,
		border_color = theme.primary,
	})

	-- slide in from the left, slide out to the right
	m.wibox.animation = {
		visible = {
			duration = 0.2,
			enter = "slide_left",
			exit = "slide_right",
		},
	}

	m.load_path_commands()

	m.initialized = true
end

m.reload_path_commands = function()
	m.load_path_commands(true)
	m.set_keyword("")
	return true, false
end

m.load_path_commands = function(clean)
	m.commands = find_executable()
end

m.is_visible = function()
	return m.wibox.visible
end

m.hide = function()
	m.wibox.ontop = false
	m.wibox.visible = false
end

m.rerender = function()
	local commands = m.matched_commands

	local offset = (m.page - 1) * m.per_page + 1
	-- out of bounds are displayed as empty
	local offset_end = m.per_page + offset - 1

	-- redraw text boxes
	local i = 1
	for k = offset, offset_end do
		local cmd = commands[k] or "--"
		local w = m.widgets.commands[i]
		w:set_markup(cmd)
		i = i + 1
	end
end

m.rerender_selection = function()
	for i = 1, m.per_page do
		local bg_widget = m.widgets.command_backgrounds[i]
		if i == m.selected then
			bg_widget.bg = selected_color
		else
			bg_widget.bg = gears.color.transparent
		end
	end
end

m.get_total_page = function()
	local nitems = #m.matched_commands
	local pp = m.per_page
	if nitems % pp == 0 then
		return nitems / pp
	else
		return math.ceil(nitems / pp)
	end
end

m.next_selection = function(keyword)
	local next_sel = math.min(m.selected + 1, #m.matched_commands)
	if next_sel > m.per_page then
		next_sel = 1
		m.page = m.page + 1
		m.rerender()
	end
	m.selected = next_sel
	m.rerender_selection()
	return true, false
end

m.prev_selection = function(keyword)
	local n = m.selected - 1
	if n == 0 then
		if m.page == 1 then
			n = 1
		else
			m.page = m.page - 1
			n = m.per_page
			m.rerender()
		end
	end
	m.selected = n
	m.rerender_selection()
	return true, false
end

m.show = function(args)
	local is_debug = args and args.debug or false
	m.wibox.ontop = true
	m.wibox.visible = true
	m.matched_commands = find_executable()
	m.rerender()
	m.rerender_selection()

	-- extra keybindings
	local hooks = {
		{ {}, "Down", m.next_selection },
		{ {}, "Up", m.prev_selection },
		{ { "Mod4" }, "r", m.reload_path_commands },
		{ { "Mod4" }, "j", m.next_selection },
		{ { "Mod4" }, "k", m.prev_selection },
		{
			{ "Mod4" },
			"h",
			function()
				ic("test")
				return true, false
			end,
		},
	}

	-- run the prompts
	local prompt = m.widgets.prompt_textbox
	m.commands = find_executable()
	m.set_keyword("")
	awful.prompt.run({
		prompt = "<b>Run: </b>",
		text = "",
		textbox = prompt,
		done_callback = m.hide,
		hooks = hooks,
		exe_callback = function(_)
			local idx = m.per_page * (m.page - 1) + m.selected
			local command = m.matched_commands[idx]
			if is_debug then
				command = "sakura --login  -e " .. command
			end
			awful.spawn.with_shell(command)
		end,
		changed_callback = function(input)
			m.matched_commands = find_executable(input)
			m.rerender()
		end,
	})
end

m.set_keyword = function(keyword)
	m.keyword = keyword
	if #keyword == 0 then
		m.matched_commands = m.commands
	else
		m.matched_commands = m.search(keyword)
	end

	m.selected = 1
	m.page = 1
	m.rerender_selection()
end

m.toggle = function(args)
	if m.is_visible() then
		m.hide()
	else
		m.show(args)
	end
end

m.run = function(args)
	m.reload_path_commands()
	m.toggle(args)
end

m.init()
m.hide()

return m
