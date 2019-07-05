local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")

beautiful.prompt_selected_fg = "#fffffff"
beautiful.prompt_selected_bg = "#2d9"
beautiful.prompt_normal_bg_1 = "#323232"
beautiful.prompt_normal_bg_2 = "#424242"
beautiful.prompt_normal_fg_1 = "#fff"
beautiful.prompt_normal_fg_2 = "#fff"
beautiful.prompt_normal_padding = dpi(8)
beautiful.prompt_prompt_padding = dpi(8)
beautiful.prompt_selected_padding = dpi(4)
beautiful.prompt_wibox_padding = dpi(4)

local function colormarkup(s, c)
	return '<span color=\'' .. c .. '\'>' .. s .. '</span>'
end --colour markup

local function get_executables()
	lfs = require("lfs")
	local execs = {}
	local added = {}
	local index = 1
	local paths = os.getenv("PATH")
	for path in string.gmatch(paths, "([^:]+)") do
		if gears.filesystem.dir_readable(path) then
			for file in lfs.dir(path) do
				if gears.filesystem.file_executable(path.."/"..file) then
					if not added[file] then
						added[file] = index
						index = index + 1
						execs[index] = file
					end
				end
			end
		end
	end
	return execs
end

local popup = awful.popup({
	bg = '#424242',
	visible = false,
	ontop = true,
	widget = wibox.widget({
		{
			widget = wibox.container.margin,
			margins = beautiful.prompt_prompt_padding,
			{
				widget = wibox.widget.textbox,
				text = '',
				id = 'prompt'
			},
		},
		wibox.layout.flex.vertical(),
		layout = wibox.layout.fixed.vertical,
		forced_width = awful.screen.focused().geometry.width / 3,
		-- forced_height = awful.screen.focused().geometry.height / 3,
	}),
	placement = awful.placement.centered
})

local prompt = {
	execs = {},
	fexecs = {}, -- filtered execs
	selected = 1,
	page = 1,
	oldcmd = '',
	perpage = 20,
}

-- notify { text = "Perpage = " .. prompt.perpage .. "\nFont height = " .. beautiful.get_font_height() .. "\nsh = " .. awful.screen.focused().geometry.height }
local function color_function(i)
	if i == prompt.selected then
		return beautiful.prompt_selected_bg or beautiful.bg_focus
	elseif i % 2 == 0 then
		return beautiful.prompt_normal_bg_1
	else
		return beautiful.prompt_normal_bg_2
	end
end

function prompt.filter(cmd, reset)
	prompt.fexecs = {}
	if not cmd then cmd = '' end
	local matchpattern = ".*" .. cmd .. ".*"
	-- for c in cmd:gmatch(".") do
	-- 	matchpattern = matchpattern .. (c or '') .. '.*'
	-- end
	local page = 1
	local found = 0
	for i,e in ipairs(prompt.execs) do
		if not prompt.fexecs[page] then prompt.fexecs[page] = {} end
		if e:match(matchpattern) then
			found = found + 1
			table.insert(prompt.fexecs[page], e)
			if found > 0 and found % prompt.perpage == 0 then page = page + 1 end
		end
	end
end

local function entry(page, i)
	local text = prompt.fexecs[prompt.page][i]
	local fg = ''
	local padding = 0
	if i == prompt.selected then
		fg = beautiful.prompt_selected_fg
		bg = beautiful.prompt_selected_bg
		padding = beautiful.prompt_selected_padding
	else
		padding = beautiful.prompt_normal_padding
		bg = beautiful.prompt_normal_bg
		fg = beautiful.prompt_normal_fg
	end
	return wibox.widget({
		widget = wibox.container.background,
		bg = color_function(i),
		{
			wibox.widget.textbox(text),
			widget = wibox.container.margin,
			margins = padding,
		}
	})
end

function prompt.generate_entry()
	local layout = wibox.layout.flex.vertical()
	if #prompt.fexecs[1] == 0 then
		for i=1,math.floor(prompt.perpage/2)-2 do
			layout:add(wibox.widget.textbox("   "))
		end
		layout:add(wibox.widget({
			widget = wibox.widget.textbox,
			align = 'center',
			text = 'no result'
		}))
		for i=1,math.floor(prompt.perpage/2)-2 do
			layout:add(wibox.widget.textbox("   "))
		end
	end
	for i =1,prompt.perpage  do
		if not prompt.fexecs[prompt.page] then return end
		if not prompt.fexecs[prompt.page][i] then break end
		layout:add(entry(page, i))
	end
	popup.widget:get_children()[2] = layout
end

awful.spawn.easy_async_with_shell("dmenu_path", function(stdout)
	prompt.execs = {}
	for e in string.gmatch(stdout, '([^\n]+)') do
		table.insert(prompt.execs, e)
	end
	table.sort(prompt.execs)
	prompt.fexecs = prompt.execs
	prompt.generate_entry()
end)

local function run()
	prompt.offset = 1
	prompt.selected = 1
	awful.prompt.run({
		prompt = "Run: ",
		done_callback = function()
			popup.visible = false
			popup.ontop = false
		end,
		hooks = {
			{{}, "Return", function()
				awful.spawn(prompt.fexecs[prompt.page][prompt.selected])
			end},
			{{"Shift"}, "Return", function()
				awful.spawn("terminal -e " .. prompt.fexecs[prompt.page][prompt.selected])
			end}
		},
		changed_callback = function(cmd, key)
			if prompt.oldcmd ~= cmd then
				prompt.selected = 1
				prompt.page = 1
			end
			prompt.filter(cmd)
			prompt.generate_entry()
		end,
		keypressed_callback = function(mod, key, cmd)
			-- if cmd == "" then return end
			prompt.oldcmd = cmd
			if  key == "Up" then
				if prompt.selected > 1 then
					prompt.selected = prompt.selected - 1
				elseif prompt.page > 1 then
					prompt.page = prompt.page - 1
					prompt.selected = prompt.perpage
				end
				prompt.generate_entry()
			elseif key == "Down" then
				if prompt.selected < #prompt.fexecs[prompt.page] then
					prompt.selected = prompt.selected + 1
				elseif prompt.page < #prompt.fexecs then
					prompt.page = prompt.page + 1
					prompt.selected = 1
				end
				prompt.generate_entry()
			elseif key == "Prior" then
				if prompt.page > 1 then
					prompt.page = prompt.page - 1
				else
					prompt.selected = 1
				end
				prompt.generate_entry()
			elseif key == "Next" then
				if prompt.page < #prompt.fexecs then
					prompt.page = prompt.page + 1
				else
					prompt.selected = #prompt.fexecs[prompt.page]
				end
				prompt.generate_entry()
			end
		end,
		textbox = popup.widget:get_children_by_id('prompt')[1]
	})
	prompt.filter()
	prompt.generate_entry()
	popup.visible = true
end

test = {
	{"Run test prompt", function() run() end}
}
