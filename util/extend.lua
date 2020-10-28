-- embrace
local gears = require("gears")
local awful = require("awful")

-- extend
gears.math.cycle = function(t, n, v)
  n = n + (v or 1)
  if n > t then
    n = 1
  elseif n < 0 then
    n = t
  end
  return t, n, v
end
