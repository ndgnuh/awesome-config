return function(f)
  return setmetatable({}, {__call = f})
end
