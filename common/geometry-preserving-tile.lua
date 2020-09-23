local awful = require"awful"
local gears = require"gears"
local fp = require"helper.fp"
local client = client
local map = fp.map

local module = gears.object{
  class = { layout = {} }
}

module.current_geometry = {}

module.save_geometry = function(self)
  self.current_geometry = map(function(c) return c.geometry end, client.get())
  self:emit_signal("geometry")
end

module.layout.inc = function(self, idx)
  self:save_geometry()
  awful.layout.inc(idx)
  self:emit_signal("layout")
end
