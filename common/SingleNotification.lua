-- Module PersistentNotification
-- Provides:
-- * SingleNotification()
--   Constructor
-- * obj(args)
--   Notify but doesn't create new notification
--   replace the previous one and show it if it
--   timedout
local module = {}

local gears = require"gears"
local naughty = require"naughty"

local module = function ()
  local nt = nil
  return function (args)
    assert(type(args) == "table", "notification argument must be table")
    if nt then
      args.replaces_id = nt.id
      naughty.notify(args)
    else
      nt = naughty.notify(args)
    end
  end
end

return module
