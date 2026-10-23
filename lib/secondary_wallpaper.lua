---A module to pick the secondary screen wallpaper
---Store that wallpaper in the cache directory
---requires zenity to open file picker
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")
local ic = require("lib.icecream")

local m = {
	picker_backends = {
		zenity = false,
		kdialog = false,
	},
	picker_backend = "zenity",
}

function m:get_command()
	assert(self.picker_backend ~= nil, "No picker back end is available")
	if self.picker_backend == "zenity" then
		return "zenity --file-selection"
	elseif self.picker_backend == "kdialog" then
		return "kdialog --getopenfilename"
	end
end

function m.cache_path()
	local cache_dir = gears.filesystem.get_cache_dir()
	local cache_name = "secondary-wallpaper.img"
	return cache_dir .. cache_name
end

function m:get_wallpaper()
	local path = self:cache_path()
	local ok = gears.filesystem.file_readable(path)
	if ok then
		return path
	end
end

function m.set_wallpaper(s)
	local imgpath = m.cache_path()
	local ok = gears.filesystem.file_readable(imgpath)
	if ok then
		awful.wallpaper({
			screen = s,
			widget = {
				{
					image = imgpath,
					upscale = true,
					downscale = true,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				halign = "center",
				tiled = false,
				widget = wibox.container.tile,
			},
		})
	else
		awful.wallpaper({
			screen = s,
			bg = beautiful.bg_normal or "#222222",
		})
	end
end

function m.pick_wallpaper()
	awful.spawn.easy_async(m:get_command(), function(stdout, _, _, retcode)
		-- User probably cancelled
		if retcode ~= 0 then
			return
		end

		-- Remove the newline
		local filepath = stdout:sub(1, #stdout - 1)

		-- Copy to the target path
		local infile = io.open(filepath, "rb")
		local outfile = io.open(m:cache_path(), "wb")
		if infile == nil then
			naughty.notification({
				title = "Wallpaper",
				message = "The wallpaper cannot be read",
			})
		elseif outfile == nil then
			naughty.notification({
				title = "Wallpaper",
				message = "Cannot save the wallpaper",
			})
		else
			local content = infile:read("*a")
			outfile:write(content)
			infile:close()
			outfile:close()
			naughty.notification({
				title = "Wallpaper",
				message = "Wallpaper saved",
			})
		end

		-- Set wallpaper
		for s in screen do
			if s ~= screen.primary then
				m:set_wallpaper()
			end
		end
	end)
end

local init_completer = gears.object({
	class = { total_step = 2, step = 0 },
	enable_properties = true,
	enable_auto_signals = true,
})

init_completer:connect_signal("property::step", function(self, step)
	if step < self.total_step then
		return
	end

	-- Completed
	for k, v in pairs(m.picker_backends) do
		if v then
			m.picker_backend = k
		end
	end
end)

awful.spawn.easy_async_with_shell("command -v zenity", function(_, _, _, retcode)
	m.picker_backends.zenity = (retcode == 0)
	init_completer.step = init_completer.step + 1
end)

awful.spawn.easy_async_with_shell("command -v kdialog", function(_, _, _, retcode)
	m.picker_backends.kdialog = (retcode == 0)
	init_completer.step = init_completer.step + 1
end)

return m
