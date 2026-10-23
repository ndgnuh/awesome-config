-- Some icon presets so that there are less
-- local surface = require("gears.surface")
-- local ic = require("lib.icecream")
local icons = {}
local resource = require("lib.resource")
local icon = resource.icon

icons.settings = icon("assets/icons/settings.svg")
icons.poweroff = icon("assets/icons/power_settings_circle_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.reboot = icon("assets/icons/restart_alt_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.logout = icon("assets/icons/logout_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.redshift = icon("assets/icons/wb_incandescent.svg")
icons.arrow_forward = icon("assets/icons/arrow_forward_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.skip_next = icon("assets/icons/skip_next_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.skip_prev = icon("assets/icons/skip_previous_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.play = icon("assets/icons/play_arrow_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.pause = icon("assets/icons/pause_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")
icons.music = icon("assets/icons/music_note_96dp_E8EAED_FILL1_wght400_GRAD0_opsz48.svg")

-- aliases
icons.shutdown = icons.poweroff
icons.restart = icons.reboot

return icons
