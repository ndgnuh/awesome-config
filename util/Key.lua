local gtable = require("gears.table")
local _ENV = gtable.clone(_ENV, false)
DataType = require("util.DataType")
Partial = require("util.Partial")
MM = require("util.MultiMethod")
awful = require"awful"
Module = {datatype = "Module"}

Module.Key = DataType("Key", Partial[1]({Module._modkey}))
Module.SKey = DataType("SKey", Partial[1]({Module._modkey, "Shift"}))
Module.CKey = DataType("CKey", Partial[1]({Module._modkey, "Control"}))
Module.SCKey = DataType("SCKey", Partial[1]({Module._modkey, "Shift", "Control"}))

Module.modkey = MM()
Module.modkey:addmethod("Module", function(m) return m._modkey end)
Module.modkey:addmethod("Module", "string", function(m, mod) m._modkey = mod; return m._modkey end)
Module.modkey:addmethod("SKey", function() return {Module._modkey, "Shift"} end)
Module.modkey:addmethod("CKey", function() return {Module._modkey, "Control"} end)
Module.modkey:addmethod("SCKey", function() return {Module._modkey, "Shift", "Control"} end)

return Module
