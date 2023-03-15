local survival = require("lib.survival")
local settings_io = survival("settings")


local default_settings = {
    terminal = "xterm",
    calendar = "gsimplecal",
    launcher = "dmenu_run",
}
local settings = settings_io.deserialize(default_settings)

-- Actions
function settings.save()
    settings_io.serialize(settings)
end

function settings.set_fn(key)
    return function(value)
        settings[key] = value
        settings.save()
    end
end
function settings.set_terminal(terminal)
    settings.terminal = terminal
    settings.save()
end

function settings.set_calendar(terminal)
    settings.calendar = calendar
    settings.save()
end


return settings
