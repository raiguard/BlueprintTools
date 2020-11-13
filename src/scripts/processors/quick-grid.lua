local area = require("lib.area")

local util = require("scripts.util")

local function quick_grid(player)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then return end

  local entities = blueprint.get_blueprint_entities()

  local GridArea = area.new(area.from_position(entities[1].position))
  local entity_prototypes = game.entity_prototypes

  -- iterate entities to calculate needed grid size
  for _, entity in pairs(entities) do
    local prototype = entity_prototypes[entity.name]
    if prototype then
      GridArea:expand_to_contain(area.center_on(prototype.collision_box, entity.position))
    end
  end

  -- ceil to outside edges
  GridArea:ceil()

  -- offset is simply how far away from 0,0 the top-left of the entities area is
  local offset = {
    x = GridArea.left_top.x,
    y = GridArea.left_top.y
  }

  -- move all entities by the offset
  for _, entity in pairs(entities) do
    entity.position.x = entity.position.x - offset.x
    entity.position.y = entity.position.y - offset.y
  end

  -- set grid dimensions and snapping mode
  blueprint.blueprint_snap_to_grid = {x = GridArea:width(), y = GridArea:height()}
  blueprint.blueprint_absolute_snapping = false

  -- set updated entities
  blueprint.set_blueprint_entities(entities)
end

return quick_grid