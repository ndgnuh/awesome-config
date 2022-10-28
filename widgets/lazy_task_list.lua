local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local return_true = function(...)
	return true
end

-- default args
local defaults = {
	-- widget template
	widget_template = {
		widget = wibox.container.background,
		id = "background_role",
		{
			widget = wibox.widget.textbox,
			id = "text_role",
		},
	},

	-- sort function
	sort = function(c1, c2)
		return c1.name <= c2.name
	end,

	-- client filter
	filter = function(c)
		return true
	end,

	-- client source
	source = function(s)
		return s.clients
	end,

	-- layout
	layout = {
		layout = wibox.layout.fixed.vertical,
	},

	-- theme
	theme = {},
}
local lazy_task_list = function(args)
	args = args or {}
	for k, v in pairs(defaults) do
		args[k] = args[k] or v
	end
	args.screen = args.screen or awful.screen.focused()

	local s = args.screen
	local w = wibox.widget({
		layout = args.layout.layout,
		spacing = args.layout.spacing,
	})

	function w.update(s)
		local clients = {}
		for i, c in ipairs(args.source(s)) do
			if args.filter(c) then
				table.insert(clients, c)
			end
		end
		w:reset()
		for i = 1, #clients do
			for j = i + 1, #clients do
				local ci = clients[i]
				local cj = clients[j]
				if args.sort(cj, ci) then
					clients[i], clients[j] = cj, ci
				end
			end
		end

		for i, c in ipairs(clients) do
			local w_i = wibox.widget(args.widget_template)
			-- text role
			local text = w_i:get_children_by_id("text_role")[1]
			text:set_markup(c.name)

			-- bg role
			local bg = w_i:get_children_by_id("background_role")[1]
			bg.bg = (client.focus == c) and beautiful.tasklist_bg_focus or beautiful.tasklist_bg_normal

			w:add(w_i)
		end
	end

	function w.update_with_client(c)
		w.update(c.screen)
	end

	-- 	w.update(args.screen)

	client.connect_signal("focus", w.update_with_client)
	return w
end

return lazy_task_list
