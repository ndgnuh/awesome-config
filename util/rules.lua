local awful = require("awful")

local module = { rules = {} }

module.add = function(self, name, rule)
  local index = #(awful.rules.rules) + 1
  self.rules[name] = { rule = rule, index = index }
  awful.rules.rules[index] = rule
  awful.rules.rules = awful.rules.rules
  return name, rule, index
end

module.get = function(self, name)
  local therule = self.rules[name]
  return therule.rule, therule.index
end

module.delete = function(self, name)
  local index = self.rules[name].index
  awful.rules.rules[index] = nil
  return name, index
end

return module
