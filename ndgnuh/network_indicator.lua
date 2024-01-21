--- This module defines a wibar widget for managing network
-- References:
-- * https://lazka.github.io/pgi-docs/index.html#NM-1.0/classes/Client.html
-- * https://lazka.github.io/pgi-docs/index.html#NM-1.0/classes/ActiveConnection.html#NM.ActiveConnection
local beautiful = require("beautiful")
local wibox = require("wibox")
local gtable = require("gears.table")
local lgi = require("lgi")
local NM = lgi.require("NM") -- network manager
local lib = require("lib")

--- https://lazka.github.io/pgi-docs/index.html#NM-1.0/classes/Client.html
-- local lgi = require("lgi")
-- local NM = lgi.NM -- network manager
-- local nm_client = NM.Client.new()
-- local m = {}

-- ic(nm_client:get_active_connections ())
-- for i, con in ipairs(nm_client:get_active_connections ()) do
--     ic(con:get_connection_type())
-- end
-- ic(nm_client)
-- -- local network_monitor = lgi.Gio.NetworkMonitor.get_default()
-- -- ic(network_monitor:get_network_available())
-- -- ic(network_monitor:get_network_metered())

local network_indicator = { mt = {} }

function network_indicator:set_connection(connection)
    network_indicator._private = connection
end

--- Create a new network indicator widget
local new = function(network_types)
    network_types = network_types or { "lan", "wifi" }

    -- Making the base widget
    local widget = wibox.widget {
        widget = wibox.widget.textbox,
        markup = "Hello",
        align = "left",
    }
    gtable.crush(network_indicator, widget, true)

    -- Create a new NM client for network data
    -- TODO: use async client
    local nm_client = NM.Client.new()

    -- Update function to update the widget when NM state changes
    -- I won't handle multiple wifi device case
    local update_function = function(nmc)
        local devices = nmc:get_all_devices()
        local wifi_device = nil
        local ethernet_device = nil
        for _, dev in ipairs(devices) do
            local type = dev:get_device_type()

            -- according to the docs, this is supposed to be
            -- the enum value, not the name of the enum, but
            -- whatever
            if type == "ETHERNET" then
                ethernet_device = dev
            elseif type == "WIFI" then
                wifi_device = dev
            end
        end

        -- Setup signals for the device
        function wifi_device:on_state_changed(dev)
            -- ic("Changed")
            local ap = wifi_device:get_active_access_point()
            if ap ~= nil then
                local ssid = tostring(ap:get_ssid():get_data())
                local strength = ap:get_strength()
                widget:set_markup(ssid .. " (" .. tonumber(strength) .. "%)")
            end
        end
        function wifi_device:on_access_point_removed(dev)
            -- ic("Changed rem ap")
            local ap = wifi_device:get_active_access_point()
            if ap ~= nil then
                local ssid = tostring(ap:get_ssid():get_data())
                local strength = ap:get_strength()
                widget:set_markup(ssid .. " (" .. tonumber(strength) .. "%)")
            end
        end
        function wifi_device:on_access_point_added(dev)
            -- ic("Changed add ap")
            local ap = wifi_device:get_active_access_point()
            if ap ~= nil then
                local ssid = tostring(ap:get_ssid():get_data())
                local strength = ap:get_strength()
                widget:set_markup(ssid .. " (" .. tonumber(strength) .. "%)")
            end
        end

        -- Get the currently activated AP
        local ap = wifi_device:get_active_access_point()
        if ap ~= nil then
            local ssid = tostring(ap:get_ssid():get_data())
            local strength = ap:get_strength()
            widget:set_markup(ssid .. " (" .. tonumber(strength) .. "%)")
        end
        -- ic("123")
        -- ic(wifi.ip4_config)
        -- ic(wifi.ip4_config.addresses)
        -- ic(wifi.ip4_config.family)
        -- ic(wifi.ip4_config.gateway)
        -- wifi.controller.on_state_changed = function(con)
        --
        --     ic("Con changed")
        -- end
    end
    update_function(nm_client)

    -- Set up NM signals, has to prepend "on" compare to what in the docs
    nm_client.on_connection_added = update_function
    nm_client.on_connection_removed = update_function
    nm_client.on_active_connection_added = update_function
    nm_client.on_active_connection_removed = update_function
    nm_client.on_any_device_added = update_function
    nm_client.on_any_device_removed = update_function

    nm_client:wireless_set_enabled(true)
    return widget
end

-- Wrap the mt call
function network_indicator.mt:__call(...) return new(...) end

return setmetatable(network_indicator, network_indicator.mt)
