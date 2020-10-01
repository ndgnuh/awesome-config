-- this is a stub module
-- provide a constructor
-- which return a table
-- with a run method
local awful = require"awful"

local module = {}
module.run = function(...)
  awful.spawn("rofi -show run")
end

return function(...) return module end
