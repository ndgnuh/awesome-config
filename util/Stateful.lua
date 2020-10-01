local module = function(f)
  return setmetatable({}, {__call = f})
end

return module
