-- rice/menu{{{
-- create a menu to switch rice
-- module:
-- * rices: list of rice name
-- * riceitems: list of items for awful.menu
-- * ricedir: the rice directory
-- * ricefield: the rice config file
-- * switchrice(name): switch to rice `name`
local awesome, module = awesome, {}
local gears = require"gears"
local awful = require"awful"
local partial = require"helper.fp".partial
--}}}

-- directories {{{
local wmdir = gears.filesystem.get_configuration_dir()
module.ricedir = wmdir .. "/rice"
-- pun intended, welcome to the rice field motherf*cker
module.ricefield = wmdir .. "/rice.conf"
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
  local fs = io.popen("ls " .. module.ricedir)
  local f = fs:read()
  while f do
    table.insert(module.rices, f)
    table.insert(module.riceitems, {f, partial(module.switchrice, f)})
    f = fs:read()
  end
end
--}}}

return module
