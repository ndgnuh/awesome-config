local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local awesome = awesome
local client = client
local root = root

local rootbuttons = gears.table.join(
  awful.button({}, 1, awesome.restart)
)
root.buttons(rootbuttons)
