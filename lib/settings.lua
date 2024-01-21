--- A wrapper around survival lib to make user settings
local survival = require("lib.survival")
local ctx = survival("settings")

local settings = { _private = {}, mt = {} }

--- Save current configuration
settings.save = function()
    ctx.serialize(settings._private)
end

--- Load current configuration
settings.load = function()
    settings._private = ctx.deserialize() or {}
end

--- Get config key
-- The key should not be "load" and "save"
function settings.mt:__index(key)
    return rawget(self._private, key)
end

--- Set config and save it
--- @param key string: The configuration key
--- @param value any: The configuration object
function settings.mt:__newindex(key, value)
    rawset(self._private, key, value)
    settings.save()
end

--- Get config with default
-- If the config key is nil, the default will be saved
--- @param key string: the config key
--- @param default any: the default config value
--- @return any: default value if the key is not set, else the configured value
settings.default = function(key, default)
    local value = settings[key]
    if value == nil then
        settings[key] = default
        settings.save()
        return default
    else
        return value
    end
end

return setmetatable(settings, settings.mt)
