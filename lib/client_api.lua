local awful = require("awful")
local gears = require("gears")
local ic = require("lib.icecream")

local m = {}
local capi = {
	awesome = awesome,
	tag = tag,
	client = client,
	root = root,
	screen = screen,
}

---Reset a client to its "bare" state
---No floating, no fullscreen, no maximize
---@param c client The client to normalize
m.normalize = function(c)
	c.floating = false
	c.fullscreen = false
	c.maximized = false
	c.maximized_vertical = false
	c.maximized_horizontal = false
end

---Normalize a client after toggling floating, for clients that ignore a plain `normalize`
---@param c client The client to normalize
m.force_normalize = function(c)
	gears.timer.delayed_call(function()
		c.floating = true
		gears.timer.delayed_call(function()
			m.normalize(c)
		end)
	end)
end

---Move a client to a volatile tag
---The tag's layout can be specified
---@param c client The client
---@param layout table The tag layout, default to `awful.layout.layouts[1]`
function m.move_to_volatile(c, layout)
	layout = layout or awful.layout.layouts[1]
	local tagname = c.class or c.name or tostring(c)
	local t = awful.tag.add(tagname, {
		screen = c.screen,
		layout = layout,
		volatile = true,
	})

	c:tags({ t })
	t:view_only()
end

---Focus a client across tags and screens
---@param c client The client
m.jumpto = function(c)
	if c and c.valid then
		--- Bizzare, some client does not have "screen" attribute
		if c.screen then
			awful.screen.focus(c.screen)
		end

		-- So weird, the same for first_tag
		if c.first_tag then
			c.first_tag:view_only()
		end

		c.minimized = false
		capi.client.focus = c
		c:raise()
	end
end

---Move the client to offset tag, cycle if the current tag is the last.
---@param c table the client
---@param delta number the offset
m._move_to_delta_tag = function(c, delta)
	local s = c.screen
	local t = c.first_tag

	-- no tag? what do you want me to do?
	if not t then
		c:move_to_tag(s.first_tag)
		return
	end

	local tags = s.tags
	local i = t.index + delta
	if i <= 0 then
		i = #tags
	elseif i > #tags then
		i = 1
	end
	c:move_to_tag(tags[i])
	tags[i]:view_only()
end

---Move client to next tag
---@param c client The client to move.
m.move_to_next_tag = function(c)
	m._move_to_delta_tag(c, 1)
end

---Move client to previous tag
---@param c client The client to move.
m.move_to_previous_tag = function(c)
	m._move_to_delta_tag(c, -1)
end

---Get all clients from all screens and tags
---@param filter function Predicate function that receives a `client` and returns `true` or `false` (optional).
---@return client[] clients List of all clients
function m.all_clients(filter)
	filter = filter or function()
		return true
	end

	local clients = {}
	for s in capi.screen do
		for _, t in pairs(s.tags) do
			for _, c in ipairs(t:clients()) do
				if filter(c) then
					table.insert(clients, c)
				end
			end
		end
	end
	return clients
end

--- Implement globaly focus history
local client_stack = {}

capi.client.connect_signal("focus", function(c)
	table.push_item_to_last(client_stack, c)
end)
capi.client.connect_signal("unmanage", function(c)
	local i = table.index_of(client_stack, c)
	if i then
		table.remove_at(client_stack, i)
	end
end)

---Focus previous client globally across screens and tags
function m.global_focus_previous()
	-- if the client stack is either empty or has only 1 client
	-- there is nothing to do
	local n = #client_stack
	if n < 2 then
		return
	end

	-- get next to last previously focsued client
	local c = client_stack[n - 1]
	if c and c.valid then
		m.jumpto(c)
	end
end

function m.inspect(c)
	local data = {}
	if c then
		data = {
			geomtry = c:geometry(),
			is_x11 = c.is_x11,
			window = c.window,
			id = c.id,
			app_id = c.app_id,
			name = c.name,
			title = c.title,
			class = c.class,
			instance = c.instance,
			pid = c.pid,
			floating = c.floating,
			-- icon_name = c.icon_name,
			urgent = c.urgent,
			size_hints = c.size_hints,
			type = c.type,
			startup_id = c.startup_id,
			requests_no_titlebar = c.requests_no_titlebar,
			role = c.role,
			above = c.above,
			below = c.below,
			transient_for = c.transient_for,
			modal = c.modal,
			is_fixed = c.is_fixed(),
			leader_window = c.leader_window,
			group_window = c.group_window,
			motif_wm_hints = c.motif_wm_hints,
		}
	end
	ic(data)
end

return m
