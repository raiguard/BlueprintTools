local util = require("scripts.util")

return function(player, delta)
  ---@type LuaItemStack
  local blueprint = util.get_blueprint(player.cursor_stack)

  if not blueprint then
    return
  end

  if not blueprint.blueprint_snap_to_grid then
    util.cursor_notification(player, {"message.bpt-blueprint-snap-to-grid-disabled"}, "utility/cannot_build")
    return
  end

  local entities = blueprint.get_blueprint_entities() or {}
  local tiles = blueprint.get_blueprint_tiles() or {}
  local build_grid_size = util.get_blueprint_largest_build_grid_size(blueprint)

  for _, entity in pairs(entities) do
    entity.position.x = entity.position.x + delta.x * build_grid_size
    entity.position.y = entity.position.y + delta.y * build_grid_size
  end

  for _, tile in pairs(tiles) do
    tile.position.x = tile.position.x + delta.x
    tile.position.y = tile.position.y + delta.y
  end

  -- Set updated objects
  blueprint.set_blueprint_entities(entities)
  blueprint.set_blueprint_tiles(tiles)
end
