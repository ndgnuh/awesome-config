local state = require.rel("state")
local widgets = require.rel("widgets")
local actions = require.rel("actions")

return {
	state = state,
	widgets = widgets,
	actions = actions,
	show = actions.show,
	stop = actions.stop,
	select_delta = actions.select_delta,
	select_next = actions.select_next,
	select_previous = actions.select_previous,
}
