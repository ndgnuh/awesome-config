--[[-- Spawn commands once, the PIDs survive WM restarts.

@usage
local spawn = require("survival").spawn
spawn.once("picom")
local pid = spawn.get_active_pid("picom")
--]]
local core = require.rel("core")
local awful = require("awful")

local spawn = {}
local ctx = core.context("spawn")

--- Key of a command in the cache
-- @param cmd : string or table command
-- @treturn string
local function key_of(cmd)
    if type(cmd) == "table" then
        return table.concat(cmd, " ")
    end
    return cmd
end

--- Check if a process is still running
-- @tparam number pid
-- @treturn boolean
local function is_running(pid)
    local fp = io.open("/proc/" .. pid .. "/stat")
    if not fp then
        return false
    end
    local stat = fp:read("*a")
    fp:close()
    -- state is the field right after "(comm)", Z = zombie
    local state = stat:match("%) (%a)")
    return state ~= nil and state ~= "Z"
end

--- Get currently active PID of a command
-- @param cmd : string or table command
-- @treturn number|nil : the PID, nil if not stored or not running
function spawn.get_active_pid(cmd)
    local pids = ctx.deserialize({})
    local pid = pids[key_of(cmd)]
    if pid and is_running(pid) then
        return pid
    end
    return nil
end

--- Spawn a command once
-- @param cmd : string or table command
-- @treturn number|nil : the PID of the (already) running command
function spawn.once(cmd)
    local pid = spawn.get_active_pid(cmd)
    if pid then
        return pid
    end

    pid = awful.spawn(cmd)
    if type(pid) == "number" then
        local pids = ctx.deserialize({})
        pids[key_of(cmd)] = pid
        ctx.serialize(pids)
        return pid
    end
    return nil
end

return spawn
