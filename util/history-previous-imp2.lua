local stack = require("stack")
local client = client
local Debug = require("Debug")

local module = {
  client_stack = stack()
}

module.previous = function()
  local c
  local idx = module.client_stack:top() - 1
  repeat
    c = module.client_stack:get(idx)
    if c and not c.valid then
      c = nil
    end
    idx = idx - 1
  until idx == 0 or (c and c.valid)
  return c
end

module.swap = function()
  local c = module.previous()
  if c then
    c:emit_signal("request::activate", "history-previous", {raise = true})
  end
end

client.connect_signal("focus", function(c)
  module.client_stack:push(c)
end)

return module
