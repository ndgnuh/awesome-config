local gtable = require("gears.table")

local module = {}

module.prototype = {
  items = {},
  length = 0,
  start = nil,
}

-- take a call back
-- map through the queue items
-- util meet the start element
module.prototype.map = function(self, callback)
  local start = self.start
  local item = self.items[start]
  assert(start && item, "circular queue: start item not found")
  local results = {}
  results[start] = callback(start)
  while item ~= start do
    results[item] = callback(item)
    item = self.items[item]
  end
  return results
end

-- enqueue item at idx of the items
module.prototype.enqueue_at = function(self, item, idx)
  local index = nil
end

module.prototype.enqueue_after = function(self, item, head)
end

module.prototype.enqueue_at = function(self, item, idx)
  local index = nil
  for k, v in pairs(self.items) do

  end
end

module.new = function()
  local queue = gtable.crush({}, module.prototype)
  return queue
end

return module
