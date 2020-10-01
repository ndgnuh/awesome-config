-- rice{{{
-- module:
-- * rices: list of rice name
-- * riceitems: list of items for awful.menu
-- * rice menu: menu for awful.menu
-- * ricedir: the rice directory
-- * ricefield: the rice config file
-- * switchrice(name): switch to rice `name`
local awesome, module = awesome, {}
local gears = require"gears"
local awful = require"awful"
local partial = require"util.Partial"
local dir = require"util.Dir"
--}}}

-- directories {{{
local wmdir = gears.filesystem.get_configuration_dir()
local ricedir = dir()
ricedir = ricedir:sub(1, #ricedir - 1)
module.rice_dir = setmetatable({__ricedir = ricedir}, {
  __call = function(self)
    return self.__ricedir
  end,
  __tostring = function(self) return self.__ricedir end
})
--}}}

-- switch rice, replace config file{{{
module.switchrice = function(name)
  local cmd = "echo " .. name .. " | tee " .. module.ricefield
  awful.spawn.easy_async_with_shell(cmd, awesome.restart)
end
--}}}

-- list rices {{{
module.rices = {}
module.riceitems = {}
-- this is only called once, and it's just ls
-- so it's ok to use popen here
-- also, more work would be done if we make this asynchorous
do
  local cmd = string.format(
  --[[>]][=[ls -d %s/*/ | xargs -I {} -P 4 basename '{}']=]
  --[[>]], module.rice_dir())
  local fs = io.popen(cmd)
  local f = fs:read()
  while f do
    table.insert(module.rices, f)
    table.insert(module.riceitems, {f, partial(module.switchrice, f)})
    f = fs:read()
  end
end
module.menu = {"Rices", module.riceitems}
--}}}

-- read/write config{{{
-- use cache dir to store config
local gfs = require("gears.filesystem")
module.config_file = gfs.get_cache_dir() .. "/rice.conf"

-- load config from cache
local def_match = "%s*(%a+)%s*=%s*([a-zA-Z0-9 ]+)"
local comment_match = "#.+"
module.read_config = function(self)
  if not gfs.file_readable(self.config_file) then
    self.config = {}
  else
    local f = io.open(self.config_file, "r")
    local key, val
    self.config = {}
    for line in f:lines() do
      if not line:match(comment_match) then
        key, val = line:match(def_match)
        self.config[key] = val
      end
    end
    f:close()
    return self.config
  end
end

module.write_config = function(self)
  local f = io.open(self.config_file, "w")
  local output = ""
  for key, val in pairs(self.config) do
    if type(key) == "number" then
      output = output .. key .. " = " .. val .. "\n"
    end
  end
  f:write(output)
  return self.config
end
--}}}

-- get/set rice{{{
module.get_current_rice = function(self)
  if not self.config then
    self:read_config()
  end
  return module.config.rice or "default"
end
module.set_current_rice = function(self, rice, theme)
  self.config.rice = rice
  if theme then
    self.config.theme = theme
  end
  self:write_config()
  --[[ @TODO validate the rice ]]
  awesome.restart()
end
module.current_rice = function(...)
  if select("#", ...) == 0 then
    return module:get_current_rice()
  else
    return module:set_current_rice(...)
  end
end
--}}}

-- load rice{{{
module.load_rice = function(self)
  local wmdir = gears.filesystem.get_configuration_dir()
  local ricename = self.current_rice()
  local ricedir = self.rice_dir():match("[^/]+$")
  -- add the rice root to path
  -- the reason is the same as above
  -- the rice's module will be used first thought
  local addtopath = {
    ricedir .. "/?.lua",
    ricedir .. "/?/init.lua",
    ricedir .. "/" .. ricename .. "/?.lua",
    ricedir .. "/" .. ricename .. "/?/init.lua",
  }
  for _, dir in ipairs(addtopath) do
    package.path = package.path .. ";"  .. wmdir .. dir
  end
  return require(ricename)
end
--}}}

return module
