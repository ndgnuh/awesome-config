-- requirements{{{
local gears = require"gears"
local awful = require"awful"
local loadmodule = require"mloader"
local wm = require"helper.wm"
local fp = require"helper.fp"
local naughty = require"naughty"
local awesome = awesome
--}}}

-- directories {{{
local wmdir = gears.filesystem.get_configuration_dir()
local ricedir = wmdir .. "/rice"
-- pun intended, welcome to the rice field motherf*cker
local ricefield = wmdir .. "/rice.conf"
--}}}

-- menu that switch rices{{{
do
  local rices = {}
  local mk_rice_switch = function(name)
    awful.spawn.easy_async_with_shell("echo " .. name .. " | tee " .. ricefield, awesome.restart)
  end
  -- this is only called once, and it's just ls
  -- so it's ok to use popen here
  -- also, more work would be done if we make this asynchorous
  local fs = io.popen("ls " .. ricedir)
  local f = fs:read()
  while f do
    table.insert(rices, {f, fp.partial(mk_rice_switch, f)})
    f = fs:read()
  end
  -- have to be global
  -- so that rice can call it
  ricemenu = awful.menu { items = rices }
end
--}}}

local rice = io.open(wmdir .. "/rice.conf"):read()

-- local Keys = require("util.Key")

-- Keys:modkey("Mod4")
--
-- require("naughty").notify{
--   text = require('gears').debug.dump_return{
--     Keys,
--     Keys:modkey(),
--   }
-- }

package.path = package.path .. (";" .. wmdir .. "util/?.lua")

urequire = function(x) return require("util." .. x) end
mrequire = function(x) return require("model." .. x) end

local module = loadmodule(rice)
