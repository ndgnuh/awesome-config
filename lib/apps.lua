local apps = {}
local gears = require("gears")

local zalo_app_id = "01KV5RPMKE0YPHJ2MJMHE089BW"

apps.zalo = {
	pattern = "FFPWA-" .. zalo_app_id,
	matcher = "firefoxpwa site launch " .. zalo_app_id,
}

apps.teams_pwa = {
	command = "chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Zalo",
	matcher = "cifhbcnohmdccbgoicgdjpfamggdegmo",
}

apps.libreoffice = {
	command = "libreoffice --norestore",
	matcher = function(c)
		return gears.string.startswith(c.class, "libreoffice")
	end,
}

apps.match = function(c, name)
	local matcher = apps[name] and apps[name].matcher
	T = type(matcher)
	if T == "string" then
		return c.class == matcher
	elseif T == "function" then
		return matcher(c)
	elseif T == "table" then
		for _, v in ipairs(matcher) do
			if v == c.class then
				return true
			end
		end
		return false
	end
	return c.class == name
end

return apps
