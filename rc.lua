-- add some directory to the path
-- so that require("dir.module") can be written as require("module")
-- reason is that important folders can be restructured without
-- changing every require call in each files
-- modules in those directories will be carefully named
-- so as to not conflict with those in the rice
local gears = require"gears"
local wmdir = gears.filesystem.get_configuration_dir()
package.path = package.path --[[
--]].. (";" .. wmdir .. "common/?.lua") --[[ common dir, util and model merged
--]].. (";" .. wmdir .. "util/?.lua") --[[ utilities like partial, debug...
--]].. (";" .. wmdir .. "model/?.lua") --[[ model for os watching, should be merged to util soon
--]]

--[[
welcome to the rice field, motherfucker
-- Papa Franku
]]
local Rice = require("Rice")
local display = os.getenv("DISPLAY")
if display == ":1" then
  Rice:load_rice("Simple")
else
  Rice:load_rice()
end
