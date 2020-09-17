local sh = re"sh"
local ic = re"icon"
local awful = re"awful"
local widget = re"wibox.widget"
local gobject = re"gears.object"
local gtable = re"gears.table"
local lgi = re"lgi"

local IBus = lgi.IBus

local script = "ibus-cycle.sh"

local module = {
	bus = IBus.Bus()
}

-- @iconmap
-- engine name = icon file
module.iconmap = {
	["Bamboo"] = "mdi-ibus-vietnamese.svg",
	["xkb:us::eng"] = "ibus-english.svg",
	["default"] = "ibus-english.svg"
}

module.widget = widget {
	widget = widget.imagebox,
	image = ic(module.iconmap['default']),
	buttons = awful.button({}, 1, partial(sh, script))
}


-- @cycle
-- cycle between ibus engine
-- the engines is defined in the script
module.cycle = partial(sh, script)

-- @key
-- the switch key
-- for binding
module.key = function(mod, key)
	awful.key(mod, key, module.cycle)
end

-- @fillwidget
-- TBA
module.fillwidget = function(containerGetter)
	awful.screen.connect_for_each_screen(function(s)
		s:connect_signal("", function(s)
			containerGetter(s):setup(module.widget)
		end)
	end)
end

-- @signal
-- update the wibox after
-- switching engine is done
-- or dump the error
sh:connect_signal(script, function(self, engine, err)
	-- ibus engine command annoyingly return the
	engine = engine:match("[a-zA-Z0-9:;]+")
	if err and err ~= "" then
		dump(err)
	else
		local img = module.iconmap[engine]
		module.widget:set_image(ic(img))
	end
end)

return module
