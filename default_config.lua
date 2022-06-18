--[[
-- DO NOT CHANGE THIS FILE
-- copy to or make your own config.lua instead
--]]
local config = {}

local function notify_unset(name, example)
	local Name = name:sub(1, 1):upper() .. name:sub(2, #name)
	local cmd = "notify-send '" .. Name .. "' 'You have not set any " .. name .. " command, set one in `config.lua`"
	if example then
		cmd = cmd .. ", maybe `" .. example .. "`"
	end
	cmd = cmd .. "'"
	return cmd
end

local function notify_default(name, default)
	local cmd = [[
	if command -v %s; then
		%s
	else
		notify-send 'missing command for "%s"' 'you have not set any command for "%s", and the default command `%s` is not found, set one in `config.lua` or install `%s`.\n- see also: `default_config.lua`.'
	fi
	]]

	return string.format(cmd, default, default, name, name, default, default)
end

--[[
-- DEFAULT COMMAND
--]]
config.calendar_command = notify_unset("calendar", "gsimplecal")
config.launcher_command = notify_default("launcher", "dmenu2")
config.terminal_command = notify_default("terminal", "xterm")

--[[
-- DEFAULT KEY BINDING
--]]
local modkey = "Mod4"
config.modkey = modkey
config.kill_client_key = { { modkey, "Shift" }, "c" }
config.focus_next_key = { { modkey }, "j" }
config.focus_previous_key = { { modkey }, "k" }
config.focus_history_key = { { modkey }, "tab" }

return config
