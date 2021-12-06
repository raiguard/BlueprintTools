local util = require("scripts.util")

local function swap_wire_colors(player)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then
    return
  end

  local entities = blueprint.get_blueprint_entities()

  for _, entity in pairs(entities) do
    if entity.connections then
      for _, connection in pairs(entity.connections) do
        local red = connection.red
        connection.red = connection.green
        connection.green = red
      end
    end
  end

  blueprint.set_blueprint_entities(entities)
end

return swap_wire_colors
