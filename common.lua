local awful = require"awful"
local gears = require"gears"
local wm = require"helper.wm"

local module = gears.object{}

local dir = debug.getinfo(1).source:sub(2):match("(.*/)")
local re = function(f)
  local filename = dir .. "common/" .. f .. ".lua"
  dump(filename)
  local ok, result = pcall(loadfile, filename)
  if type(result) == "function" then
    result(module)
  else
    dump(result)
  end
end

module:connect_signal("add", function(self, signal, callback)
  self:connect_signal(signal, callback)
end)

re("taskswitcher")
module:emit_signal("add", "rofi", function(_, mod, key)
  mod = mod or {"Mod4"}
  key = key or "r"
  local wm = require"helper.wm"
  local awful = require"awful"
  wm.addkeys(awful.key(mod, key, function()
    awful.spawn("rofi -show combi -modi")
  end))
end)

-- use/usewith{{{
-- use(...): use some module without argument
-- usewith(name, ...): use a module with some arguments
module.use = function(...)
  local narg = select("#", ...)
  for i = 1, narg do
    module[select(i, ...)]()
  end
end
module.usewith = function(use, ...)
  return module[use](...)
end
--}}}

-- environment{{{
module.environment = {}
module.environment.__call = function(self, ...)
  local narg = select("#", ...)
  if narg == 0 then
    return self
  else
    local key = select(1, ...)
    if narg == 1 then
      return rawget(self, key)
    elseif narg == 2 then
      local val = select(2, ...)
      rawset(self, key, val)
      return val
    end
  end
end
module.environment = setmetatable(module.environment, {__call = module.environment.__call})
--}}}

-- modifier{{{
module.modifier = function(self, modkey)
  assert(modkey, "Must call with modkey")
  self.environment("modkey", modkey)
  return modkey
end
--}}}

-- globalkeys{{{
module.globalkeys = function(modkey)
  local modkey = "Mod4"
  local mod = {modkey}
  local modshift = {modkey, "Shift"}
  local modctrl = {modkey, "Control"}
  wm.addkeys(
    awful.key(mod, "Left", awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
    awful.key(mod, "Right", awful.tag.viewnext,
      {description = "view next", group = "tag"}),
    awful.key(mod, "Escape", awful.tag.history.restore,
      {description = "go back", group = "tag"}),
    awful.key(modshift, "j", function () awful.client.swap.byidx( 1) end,
      {description = "swap with next client by index", group = "client"}),
    awful.key(modshift, "k", function () awful.client.swap.byidx( -1) end,
      {description = "swap with previous client by index", group = "client"}),
    awful.key(modctrl, "j", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
    awful.key(modctrl, "k", function () awful.screen.focus_relative(-1) end,
      {description = "focus the previous screen", group = "screen"}),
    awful.key(mod, "u", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),
    -- Standard program
    awful.key(modctrl, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
    awful.key(modshift, "e", awesome.quit,
      {description = "quit awesome", group = "awesome"}),

    awful.key(mod, "l", function () awful.tag.incmwfact( 0.05) end,
      {description = "increase master width factor", group = "layout"}),
    awful.key(mod, "h", function () awful.tag.incmwfact(-0.05) end,
      {description = "decrease master width factor", group = "layout"}),
    awful.key(modshift, "h", function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
    awful.key(modshift, "l", function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
    awful.key(modctrl, "h", function () awful.tag.incncol( 1, nil, true) end,
      {description = "increase the number of columns", group = "layout"}),
    awful.key(modctrl, "l", function () awful.tag.incncol(-1, nil, true) end,
      {description = "decrease the number of columns", group = "layout"}),
    awful.key(modshift, "space", function () awful.layout.inc(-1) end,
      {description = "select previous", group = "layout"}),
    awful.key(modshift, "n",
      function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
          c:emit_signal(
            "request::activate", "key.unminimize", {raise = true}
            )
        end
      end,
      {description = "restore minimized", group = "client"}),
    -- Menubar
    awful.key(mod, "p", function() require"menubar".show() end,
      {description = "show the menubar", group = "launcher"})
    )
end
--}}}

-- brightness{{{
local nomod = {}
wm.addkeys(
  awful.key(nomod, "XF86MonBrightnessUp", function()
    awful.spawn("light -A 6")
  end),
  awful.key(nomod, "XF86MonBrightnessDown", function()
    awful.spawn("light -U 6")
  end)
  )
-- brightness}}}

return module
