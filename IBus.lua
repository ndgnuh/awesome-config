-- module doc{{{
-- @TODO: watch on connect, on disconnect
-- this module should provide these functionality:
-- * cycle e1, e2, ...
-- * get
-- * watch callback
-- * key mod key
-- * button mod button
--
local sh = require"sh"
local ic = require"icon"
local awful = require"awful"
local gobject = require"gears.object"
local lgi = require"lgi"
local IBus = lgi.IBus
--}}}

local script = "ibus-cycle.sh"

local module = gobject {
  class = { bus = IBus.Bus() }
}

local list_engine_desc = {--{{{
  "author",
  "description",
  "hotkeys",
  "icon",
  "icon",
  "language",
  "layout",
  "layout",
  "layout",
  "license",
  "longname",
  "name",
  "rank",
  "setup",
  "symbol",
  "textdomain",
  "version"
}--}}}

local describe = function (engine_desc)--{{{
  local result = {}
  if engine_desc then
    for _, key in pairs(list_engine_desc) do
      result[key] = engine_desc[key]
    end
  end
  return result
end--}}}

-- @get{{{
-- returns current the global engine description
module.get =
  function (self)
    local engine_desc =
      self.engine or
      self.bus:get_global_engine()
    if not self.engine then
      self.engine = engine_desc
    end
    return
      describe(engine_desc)
  end
--}}}

-- @set{{{
-- set global engine
module.set = function(self, name)
  self.bus:set_global_engine(name)
end
--}}}

-- @setup{{{
-- set the list of engine to cycle
module.setup = function (self, engines)
  self.engines = engines
  return engines
end
--}}}

-- @cycle{{{
-- cycle between ibus engine
-- the engines is defined in the script
-- module.cycle = partial(sh, script)
module.cycle = function (self, engines)
  engines = engines or self.engines
  local idx = 1
  local current_engine = self.bus:get_global_engine()
  if not current_engine then
    self.bus:set_global_engine(engines[1])
    return
  end
  local current_name = current_engine.name
  for i, enginename in ipairs(engines) do
    if enginename == current_name then
      idx = i + 1
      break
    end
  end
  if idx > #engines then
    idx = 1
  end
  local newengine = engines[idx]
  self.bus:set_global_engine(newengine)
end
--}}}

-- key and buttons{{{
-- the switch key
-- for binding
module.key = function (mod, key, engines)
  return
    awful.key(mod, key, partial2(module.cycle, module, engines))
end
module.button = function (mod, btn, engines)
  return
    awful.button(mod, btn, partial2(module.cycle, module, engines))
end
--}}}

-- @watch{{{
-- signal connecter
module.watch =
  function(self, callback)
    module.bus.on_global_engine_changed =
      function(bus, name)
        local engine = bus:get_engines_by_names({name})[1]
        callback(describe(engine) or {})
      end
  end
--}}}

-- reset cache after change engine [[{{{
module.watch(
  function()
    module.engine = nil
  end
)
--]]}}}

module.bus:set_watch_ibus_signal(true)
return module
