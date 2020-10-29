local util = require("scripts.util")

local function quick_grid(player)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then return end

  blueprint.blueprint_snap_to_grid = {x = 1, y = 1}
  blueprint.blueprint_absolute_snapping = true

  local entities = blueprint.get_blueprint_entities()

  for _, entity in pairs(entities) do

  end
end

return quick_grid