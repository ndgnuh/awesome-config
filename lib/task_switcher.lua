--- this is the newer one
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local ic = require("lib.icecream")
local capi = { client = client, screen = screen }

local TaskSwitcher = {}

function TaskSwitcher:select(idx)
	self._private.selected_index = idx
	self:update()
end

function TaskSwitcher:attach_wibox(wb)
	self:connect_signal("start", function()
		wb.visible = true
		wb.ontop = true

		local s = awful.screen.focused()
		local g = s.geometry
		local w = g.width * 0.7
		local h = w * 9 / 16
		wb.x = (g.width - w) * 0.5
		wb.y = (g.height - h) * 0.5
		wb.width = w
		wb.height = h
	end)

	self:connect_signal("stop", function()
		gears.timer.delayed_call(function()
			wb.visible = false
			wb.ontop = false
		end)
	end)

	wb.widget = self
end

function TaskSwitcher:set_release_key(key)
	self._private.release_key = key
end

function TaskSwitcher:set_next_key(key)
	self._private.next_key = key
end

function TaskSwitcher:set_previous_key(key)
	self._private.previous_key = key
end

local started = false
function TaskSwitcher:start()
	if started then
		return
	end
	self:emit_signal("start")

	local this = self
	local next_key = self._private.next_key or "j"
	local previous_key = self._private.previous_key or "k"
	local release_key = self._private.release_key or "Super_L"
	local grabber = awful.keygrabber({
		timeout = 2,
		stop_callback = function()
			gears.timer.delayed_call(function()
				this:emit_signal("stop")
				started = false
				local idx = this._private.selected_index
				local clients = this._private.clients
				if not idx or not clients then
					return
				end

				local c = clients[idx]
				if not c then
					return
				end

				local libclient = require("lib.client_api")
				libclient.jumpto(c)
			end)
		end,
		start_callback = function()
			local idx = table.index_of(self._private.clients, capi.client.focus)
			this:select(idx or 1)
		end,
		keypressed_callback = function(self, mod, key)
			if key == "Escape" then
				self:stop()
			elseif key == next_key then
				this:select_next()
			elseif key == previous_key then
				this:select_previous()
			end
		end,
		keyreleased_callback = function(self, mod, key)
			if key == release_key then
				self:stop()
			end
		end,
	})

	grabber:start()
end

function TaskSwitcher:select_delta(delta)
	local n = #self._private.clients
	local i = self._private.selected_index + delta
	if i > n then
		i = 1
	elseif i <= 0 then
		i = n
	end
	self._private.selected_index = i
	self:select(i)
end

function TaskSwitcher:select_next()
	self:select_delta(1)
end

function TaskSwitcher:select_previous()
	self:select_delta(-1)
end

function TaskSwitcher:update()
	local all_clients = TaskSwitcher.all_clients()
	self._private.clients = all_clients
	local listview = self._private.listview
	local selected_index = self._private.selected_index

	-- Update list view
	listview:reset()
	for i, c in ipairs(all_clients) do
		local bg
		if i == selected_index then
			bg = "#f00"
		end
		local tile = wibox.widget({
			widget = wibox.container.constraint,
			width = 300,
			{
				widget = wibox.container.background,
				bg = bg,
				{
					widget = wibox.widget.ListTile,
					title = tostring(c.name),
					subtitle = "class: " .. tostring(c.class) .. ", tag: " .. tostring(c.first_tag.index),
				},
			},
		})
		listview:add(tile)
	end

	-- update preview
	local selected_client = all_clients[selected_index]
	gears.timer.delayed_call(function()
		local preview = self._private.preview
		local preview_text = self._private.preview_text
		local content = selected_client.content
		if content then
			preview_text.markup = "<span>Preview</span>"
			preview.image = content
		else
			preview_text.markup = "<span color='#fff'>No preview available</span>"
			preview.image = nil
		end
	end)
end

TaskSwitcher.all_clients = function()
	local cs = {}
	for s in capi.screen do
		for _, t in pairs(s.tags) do
			for _, c in ipairs(t:clients()) do
				table.insert(cs, c)
			end
		end
	end
	return cs
end

function TaskSwitcher.new()
	local client_listview = wibox.layout.fixed.vertical()
	local client_preview = wibox.widget.imagebox()
	local client_preview_text = wibox.widget.textbox()
	client_preview_text.align = "center"
	local proxy = wibox.widget({
		widget = wibox.layout.align.horizontal,
		client_listview,
		{
			widget = wibox.container.place,
			{
				widget = wibox.layout.stack,
				client_preview,
				client_preview_text,
			},
		},
	})

	local ret = wibox.widget.base.make_widget(proxy, "TaskSwitcher", { enable_properties = true })
	gears.table.crush(ret, TaskSwitcher, true)

	-- widgets and state
	ret._private.listview = client_listview
	ret._private.preview = client_preview
	ret._private.preview_text = client_preview_text
	ret._private.selected_index = 1
	ret._private.is_active = false
	ret:attach_wibox(wibox())

	--- initial stuffs
	ret:set_next_key("j")
	ret:set_previous_key("k")
	ret:set_release_key("Super_L")

	-- Update when there are new client
	ret:update()
	ret:select(1)
	local update = function()
		ret:update()
	end
	capi.client.connect_signal("manage", update)
	capi.client.connect_signal("unmanage", update)

	return ret
end

local instance
function TaskSwitcher.get_instance()
	if not instance then
		instance = TaskSwitcher.new()
	end
	return instance
end

return setmetatable(TaskSwitcher, { __call = TaskSwitcher.new })
