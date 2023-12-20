local flib_bounding_box = require("__flib__.bounding-box")
local table = require("__flib__.table")

local constants = require("constants")
local util = require("scripts.util")

local function quick_grid(player)
  local player_table = global.players[player.index]

  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then
    return
  end

  local entities = blueprint.get_blueprint_entities() or {}
  local tiles = blueprint.get_blueprint_tiles() or {}

  local first_obj = entities[1] or tiles[1]

  local box = flib_bounding_box.from_position(first_obj.position)
  local entity_prototypes = game.entity_prototypes

  -- iterate entities and tiles to calculate needed grid size
  for _, entity in pairs(entities) do
    local prototype = entity_prototypes[entity.name]
    if prototype then
      local entity_box = (
        prototype.type == "curved-rail"
          and table.deep_copy(constants.curved_rail_grid_sizes[math.floor((entity.direction or 0) / 2) % 2 + 1])
        or prototype.collision_box
      )
      box = flib_bounding_box.expand_to_contain_box(box, flib_bounding_box.move(entity_box, entity.position))
    end
  end
  if player_table.settings.consider_tiles_for_quick_grid then
    for _, tile in pairs(tiles) do
      -- add 0.5 to tile position to avoid off-by-one error on the right and bottom edges
      box = flib_bounding_box.expand_to_contain_position(box, { x = tile.position.x + 0.5, y = tile.position.y + 0.5 })
    end
  end

  -- ceil to outside edges
  box = flib_bounding_box.ceil(box)

  -- offset is simply how far away from 0,0 the top-left of the area is
  local offset = { x = box.left_top.x, y = box.left_top.y }

  -- move all entities and tiles by the offset
  for _, entity in pairs(entities) do
    entity.position.x = entity.position.x - offset.x
    entity.position.y = entity.position.y - offset.y
  end
  for _, tile in pairs(tiles) do
    tile.position.x = tile.position.x - offset.x
    tile.position.y = tile.position.y - offset.y
  end

  -- set grid dimensions and snapping mode
  local result = { x = flib_bounding_box.width(box), y = flib_bounding_box.height(box) }
  local existing_snap = blueprint.blueprint_snap_to_grid
  if existing_snap and existing_snap.x == result.x and existing_snap.y == result.y then
    -- Swap absolute snapping setting
    blueprint.blueprint_absolute_snapping = not blueprint.blueprint_absolute_snapping
    return
  end
  blueprint.blueprint_snap_to_grid = { x = flib_bounding_box.width(box), y = flib_bounding_box.height(box) }
  blueprint.blueprint_absolute_snapping = false

  -- set updated entities
  blueprint.set_blueprint_entities(entities)
  blueprint.set_blueprint_tiles(tiles)
end

return quick_grid
