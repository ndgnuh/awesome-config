local overdrip = require("lib.overdrip")
local allclients = require("providers.clients")

local m = {}

m.enabled_provider = overdrip.provider(false)
m.selection_index_provider = overdrip.provider(1)
m.selected_client_provider = overdrip.provider(function(ref)
	local i = ref:watch(m.selection_index_provider)
	local clients = ref:watch(allclients.clients_provider)
	return clients[i]
end)

return m
