local m = {
	first_run = true,
}

awesome.connect_signal("exit", function(restart)
	if restart then
		m.first_run = false
	end
end)

return m
