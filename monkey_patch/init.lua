local gears = require("gears")

require("monkey_patch._awesome")
require("monkey_patch._table")
require("monkey_patch._awful_client")

gears.debug.ic = require("lib.icecream")
