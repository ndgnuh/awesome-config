local gears = require("gears")
local ruled = require("ruled")
local awful = require("awful")
local apps = require("lib.apps")

ruled.client.connect_signal("request::rules", function()
	-- @DOC_GLOBAL_RULE@
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
		callback = function(c)
			if not c.valid then
				c:kill()
			end
		end,
	})

	-- transient windows
	ruled.client.append_rule({
		id = "transient",
		rule_any = {},
		callback = function(c)
			local tc = c.transient_for
			if tc then
				c.floating = true
				c.sticky = false
				c.above = true
			end
		end,
	})

	-- @DOC_FLOATING_RULE@
	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = require("rules.floating_sticky_clients"),
		properties = {},
		callback = function(c)
			-- Do not set ontop = true for dialogs
			-- They *will* crash the WM.
			-- Except for some other class
			-- if c.type ~= "dialog" or c.class == "dragon-drop" then
			-- 	c.ontop = true
			-- end
			gears.timer.delayed_call(function()
				c.ontop = true
				return false
			end)
			c.above = true
			c.floating = true
			c.sticky = true
			c.titlebars_enabled = true
			c.placement = awful.placement.no_offscreen + awful.placement.centered
		end,
	})

	-- Rules for dialog
	-- Can't have on-top, property set to true, because
	-- it will crash the WM
	ruled.client.append_rule({
		id = "dialogs",
		rule_any = { type = { "dialog" } },
		properties = {
			placement = awful.placement.no_offscreen + awful.placement.centered,
		},
	})

	-- Rules for Zalo.exe
	-- For some reason, it does not display properly at the start
	ruled.client.append_rule({
		id = "zalo",
		rule_any = { class = { "zalo.exe", "Zalo.exe" } },
		properties = {
			floating = true,
			placement = awful.placement.no_offscreen + awful.placement.centered,
		},
		callback = function(c)
			gears.timer.delayed_call(function()
				awful.client.move_to_volatile(c)
				awful.client.normalize(c)
				return false
			end)
		end,
	})

	--- All normal clients are moved to volatile tag
	ruled.client.append_rule({
		id = "volatile",
		rule_any = { type = { "normal" } },
		callback = function(c)
			if gears.string.startswith(c.class, "xdg-desktop-portal") then
				c.floating = true
				awful.placement.centered(c)
				return
			end

			--- Keep fullscreen clients fullscreen
			if c.fullscreen then
				return
			end

			if c.transient_for then
				c.floating = true
				c.above = true
				awful.placement.centered(c)
				return
			end

			local pid = c.pid
			local fc = client.focus
			if fc and fc.pid == pid then
				if apps.match(c, "libreoffice") then
				else
					c.floating = true
					c.above = true
					awful.placement.centered(c)
					return
				end
			end

			if not c.floating and c.type == "normal" then
				-- awful.client.force_normalize(c)
				awful.client.move_to_volatile(c)
			else
				awful.placement.centered(c)
			end
		end,
	})

	-- @DOC_DIALOG_RULE@
	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		-- @DOC_CSD_TITLEBARS@
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	})

	ruled.client.append_rule({
		id = "Julia Makie",
		rule = { class = "GLWindow", name = "Makie" },
		properties = { floating = true, ontop = true },
	})
end)
