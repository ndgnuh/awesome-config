--- This module contain the widget that monitor IBus
-- The implementation use lgi instead of shell script.
-- The module also take inspiration from the textclock widget.
-- Reference: https://lazka.github.io/pgi-docs/IBus-1.0/classes/Bus.html
local textbox = require("wibox.widget.textbox")
local gtable = require("gears.table")
local lgi = require("lgi")
local IBus = lgi.IBus

local ibus = { mt = {} }

--- Set formatting string
--- @param format string: format string, can be "name", "longname" or "language"
function ibus:set_format(format)
    self._private.format = format
    self:update()
end

--- Get formatting string
--- @return string: format string, can be "name", "longname" or "language"
function ibus:get_format(format)
    return self._private.format
end

--- Set ibus widget engine
-- See also: https://lazka.github.io/pgi-docs/IBus-1.0/classes/EngineDesc.html#IBus.EngineDesc
--- @param self table: the widget instance
--- @param engine IBus.EngineDesc: Engine description
ibus.set_engine = function(self, engine)
    self._private.engine = engine
    self:update()
end

--- Get return the current ibus engine
-- See also: https://lazka.github.io/pgi-docs/IBus-1.0/classes/EngineDesc.html#IBus.EngineDesc
--- @return Ibus.EngineDesc: Engine description.
ibus.get_engine = function(self)
    return self._private.engine
end

--- Update the ibus widget
--- @param self table: the widget instance
ibus.update = function(self)
    local format = self._private.format
    local engine = self._private.engine
    if engine then
        local fmt = engine[format]
        self:set_markup(fmt)
    end
end

--- Create a ibus widget
-- This function follows the declarative convention of awesome
--- @param format string: the format of the widget, can be name, longname, or language.
local new = function(format)
    -- Input validation
    format = format or "name"
    assert(format == "name"
        or format == "longname"
        or format == "language",
        "IBus engine format must be name, longname or language")

    -- Base widget to work on
    local w = textbox()
    gtable.crush(w, ibus, true)
    w._private.format = format

    -- ibus init
    local bus = IBus.Bus.new_async_client()
    bus:set_watch_ibus_signal(true)

    -- update ibus widget when this is connected
    function bus:on_connected()
        local engine = self:get_global_engine()
        w:set_engine(engine)
    end

    -- update widget when global engine change
    function bus:on_global_engine_changed()
        local engine = bus:get_global_engine()
        w:set_engine(engine)
    end

    -- wrap widget
    return w
end

function ibus.mt:__call(...) return new(...) end
return setmetatable(ibus, ibus.mt)
