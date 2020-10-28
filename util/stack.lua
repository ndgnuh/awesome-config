local module = {}

-- prototype
-- module.prototype.push(item)
-- module.prototype.pop()
-- module.prototype.top(?)
-- module.prototype.insert(pos)
-- module.prototype.insert_or_push(item)
-- module.prototype.items()
-- module.prototype.get()
module.prototype = {__items = {}, __top = 0}

module.prototype.push = function(self, item)
  self.__top = self.__top + 1
  self.__items[self.__top] = item
  return item
end

module.prototype.pop = function(self)
  local top = self:top()
  local item = self.__items[top]
  self.__top = top - 1
  return item
end

module.prototype.top = function(self)
  return self.__top
end

module.prototype.items = function(self)
  return self.__items
end

module.prototype.insert = function(self, i)
  local top = self:top()
  local ith_item = self.__items[i]
  self.__item[i] = self.__items[top]
  self.__item[top] = ith_item
  return i
end

module.prototype.get = function(self, i)
  assert(type(i) == 'number', 'index is not number')
  if i > self.__top then
    return nil
  else
    return self.__items[i]
  end
end

module.prototype.insert_or_push = function(self, item)
  local idx = 1
  for i, v in ipairs(self.__items) do
    if v == item then
      idx = v
      break
    end
  end
end

return setmetatable(module, {
  __call = function(self)
    local gtable = require("gears.table")
    return setmetatable(gtable.crush({}, self.prototype), {__name = "stack"})
  end
})
