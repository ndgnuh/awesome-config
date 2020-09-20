-- module loader
-- the idea is append the module path to package.path,
-- so that the `require` prior the file it found in the submodule folder

local wmdir = debug.getinfo(1).source:sub(2):match("(.*/)")

local module = function(name)
  local oldpath = package.path
  local loadfiles = wmdir .. "./" .. name .. "/?.lua"
  local loadfolders = wmdir .. "./" .. name .. "/?/init.lua"
  package.path = string.format("%s;%s;%s", loadfiles, loadfolders, oldpath)
  local module = require(name)
  package.path = oldpath
  return module
end

return module
