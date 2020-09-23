-- module rice loader
-- the idea is append the module path to package.path,
-- so that the `require` prior the file it found in the submodule folder
local wmdir = debug.getinfo(1).source:sub(2):match("(.*/)")

local module = function(name)
  local oldpath = package.path
  local l0 = wmdir .. "rice/?.lua;" .. wmdir .. "rice/?/init.lua;"
  local l1 = wmdir .. "rice/" .. name .. ".lua;"
  local l2 = wmdir .. "rice/" .. name .. "/?.lua;"
  local l3 = wmdir .. "rice/" .. name .. "/?/init.lua;"
  package.path = l0 .. l1 .. l2 .. l3 .. package.path
  local module = require(name)
  package.path = oldpath
  return module
end

return module
