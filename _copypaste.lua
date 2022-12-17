local awful = require("awful")

local beautiful = require("beautiful")

local widget = require("wibox.widget")
local container = require("wibox.container")
local layout = require("wibox.layout")

local gears = require("gears")

local shape = require("gears.shape")
local color = require("gears.color")

local capi = {
    awesome = awesome,
    root = root,
    client = client
}
