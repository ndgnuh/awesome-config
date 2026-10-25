local gears = require("gears")

local Scheduler = {
	states_to_refresh = {}, -- list of providers to recompute
}

function Scheduler:schedule_to_refresh(provider)
	for _, v in pairs(self.states_to_refresh) do
		-- Already in the scheduler
		if v == provider then
			return
		end
	end

	-- Insert
	table.insert(self.states_to_refresh, provider)
end

function Scheduler:perform_refresh()
	while #self.states_to_refresh > 0 do
		local element = table.remove(self.states_to_refresh, 1)
		element:flush()
	end
end

function Scheduler.new()
	local s = gears.table.clone(Scheduler, true)
	awesome.connect_signal("refresh", function()
		s:perform_refresh()
	end)
	return s
end

return Scheduler
