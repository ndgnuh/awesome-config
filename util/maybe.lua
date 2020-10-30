return function(func, ...)
  if not func then return end
  local narg = select("#", ...)
  for i = 1, narg do
    if not select(i, ...) then
      return
    end
  end
  return func(...)
end
