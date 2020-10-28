local gtable = require("gears.table")
local gobject = require("gears.object")
local gtimer = require("gears.timer")
local dump = require("Debug").dump
local insert = table.insert

-- module.history
-- assume there's two client `c1` `c2`
-- history[x-1] = c1
-- history[x] = c2
-- then c1 is the previous client of c2
local module = gobject{
  class = {
    lock = false,
    max_sparsity = 100,
    sparsity = 0,
    maxn = 0,
    managed = {},
    history = {},
    invindex = {},
    __previous = nil
  }
}

-- timer to clean history table
module.cleaner_timer = gtimer {
  timeout = 180,
  callback = function()
    if not module.lock then
      module.history = gtable.from_sparse(module.history)
      for i, c in ipairs(module.history) do
        module.invindex[c] = i
      end
      module.maxn = #module.history
      module:emit_signal("sparse::clean")
    end
  end
}
module.cleaner_timer:start()

-- get/set cleaner timeout
module.clear_timeout = function(timeout)
  if type(timeout) == "number" then
    module.cleaner_timer.timeout = timeout
  else
    return module.cleaner_timer.timeout
  end
end

-- module.previous()
-- get previous client
-- the loop is in case there's nil value (client unmanaged)
module.previous = function()
  module.lock = true
  local top = #module.history - 1
  while not module.history[top]
    and module.history[top] == client.focus
    and top > 0 do
    top = top - 1
  end
  dump(client.focus, module.history, module.invindex)
  local prev = module.history[top]
  module.lock = false
  return prev -- it can still be nil
end

-- swap with the previous client
module.swap = function(raise)
  local success = false
  raise = raise or true
  module:emit_signal("before::swap")
  local previous = module.previous()
  if previous then
    previous:emit_signal("request::activate", "module.swap", {raise = raise})
    success = true
  end
  module:emit_signal("after::swap", success)
end

-- signal/focus
-- when a client is focused
-- send it to the history
-- because somehow, module.history is run after the signal
-- so there must be a blockage
client.connect_signal("focus", function(c)
  module.lock = true
  local pos = module.invindex[c]
  if pos then
    module.history[pos] = nil
  end
  table.insert(module.history, c)
  module.maxn = module.maxn + 1
  module.invindex[c] = module.maxn
  module.lock = false
end)

-- signal/unmanage
-- when a client is unmanaged by awesome
-- then remove it from module.history (set to nil)
-- and from module.managed
client.connect_signal("unmanage", function(c)
  module.lock = true
  local pos = module.invindex[c]
  if pos then
    module.history[pos] = nil
    module.invindex[c] = nil
  end
  module.lock = false
end)

-- signal/unfocus
-- When a client `c` is unfocused set __previous to it
-- this is not the true previous client as the client
-- can be unmanaged, use module.previous() instead
client.connect_signal("unfocus", function(c)
  module.__previous = c
end)

return module
