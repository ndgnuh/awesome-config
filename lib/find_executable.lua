local GLib = require("lgi").GLib

--- List executables in PATH whose name contains `keyword` (case-insensitive).
--- Lua port of libez.find_executable.
--- @param keyword string|nil
--- @return string[] # sorted, deduplicated executable names
local function find_executable(keyword)
	local path_env = os.getenv("PATH")
	if not path_env then
		return {}
	end

	local matcher = keyword and keyword:lower()
	local seen = {}
	local ret = {}

	for dir in path_env:gmatch("[^:]+") do
		-- No explicit close: lgi frees the GDir on GC, closing it here double-frees
		local handle = GLib.Dir.open(dir, 0)
		if handle then
			for name in handle.read_name, handle do
				if
					not seen[name]
					and (not matcher or name:lower():find(matcher, 1, true))
				then
					local full_path = GLib.build_filenamev({ dir, name })
					if
						GLib.file_test(full_path, "IS_REGULAR")
						and GLib.file_test(full_path, "IS_EXECUTABLE")
					then
						seen[name] = true
						ret[#ret + 1] = name
					end
				end
			end
		end
	end

	table.sort(ret)
	return ret
end

return find_executable
