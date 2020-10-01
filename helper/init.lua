local module, helpers = {}, {"fp", "wm"}

for _, name in pairs(helpers) do
  helpers[h] = require("helper." .. name)
end

return helpers

