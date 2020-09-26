-- # Sample usage
-- vtable = {
--     [{"string", "string"}] = function(x, y) return x .. y end,
--     [{"string", "number"}] = function(x, y) return x .. tostring(y + 1) end,
--     [{"number"}] = function(x) return x + 1 end,
--     [{}] = function() print("hello world") end
-- }
-- f = multimethod(vtable)
-- calls:
-- f("hello", "world")
-- f("hello", 1)
-- f(1)
-- f()
local module = {}
local unpack = unpack or table.unpack

-- each keys create a table, the first element of the table is the dispatch{{{
local chainset = function(t, ...)
    local node = t
    local narg = select("#", ...)
    local lastarg = select(narg, ...)
    assert(type(lastarg) == "function" or type(lastarg) == "table", "Dispatch is not a method")
    for i = 1, (narg - 1) do
        local ar = select(i, ...)
        if type(node[ar]) == "nil" then
            node[ar] = {}
        end
        node = node[ar]
    end
    node[1] = lastarg
    return t
end
--}}}

-- get the function depends on the data type{{{
local chainget = function(t, ...)
    local node = t
    local narg = select("#", ...)
    for i = 1, narg do
        local argtype = type(select(i, ...))
        node = node[argtype]
    end
    return node[1]
end
--}}}

-- create new function base on method definition{{{
module.new = function(self, vtable)
  local selfmodule = self
    local vt = {}
    -- call method
    local call = function(self, ...)
      local f = chainget(self, ...)
      assert(f, "No such method")
      return chainget(self, ...)(...)
    end
    -- if there's a vtable then append the method
    if type(vtable) == "table" then
      for dispatch, method in pairs(vtable) do
        table.insert(dispatch, method)
        chainset(vt, unpack(dispatch))
      end
    end
    -- add new method to function
    vt.add = function(self, ...)
      chainset(self, ...)
      return self
    end
    -- return multimethod function
    return setmetatable(vt, {__call = call})
end
--}}}

--{{{
return setmetatable(module, {__call = module.new})
--}}}
