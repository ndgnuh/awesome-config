local awful = require('awful')

local m = {}

function m.move(c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
	c.maximized = false
	local t = c.first_tag
	if not t then return end
	if t.layout.name ~= "floating" then
		c.floating = true
	end
	awful.mouse.client.move(c)
end

function m.reset(c)
	local props = {
		"floating";
		"ontop";
		"sticky";
		"marked";
		"maximized";
		"fullscreen";
	}
	for _, prop in pairs(props) do
		c[prop] = false
	end
end

return m
