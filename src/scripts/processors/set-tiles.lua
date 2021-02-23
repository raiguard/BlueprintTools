local area = require("__flib__.area")

local util = require("scripts.util")

return function(player, tile_name, fill_gaps, margin)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then return end

  local entities = blueprint.get_blueprint_entities()
  local entity_prototypes = game.entity_prototypes

  local tiles = {}
  local tile_index = 0

  if fill_gaps then
    local TileArea = area.load(area.from_position(entities[1].position))

    -- iterate entities to calculate needed grid size
    for _, entity in pairs(entities) do
      local prototype = entity_prototypes[entity.name]
      if prototype then
        TileArea:expand_to_contain_area(area.move(prototype.collision_box, entity.position))
      end
    end

    -- ceil to outside edges and add a margin
    TileArea:ceil():expand(margin)

    -- for the purpose of this function, we don't care about any pre-existing tiles - we will replace all of them
    for position in TileArea:iterate() do
      tile_index = tile_index + 1
      tiles[tile_index] = {
        position = position,
        name = tile_name
      }
    end
  else
    local mapping = {}
    local function add_tile(position)
      local add = false

      if mapping[position.x] then
        if not mapping[position.x][position.y] then
          add = true
          mapping[position.x][position.y] = true
        end
      else
        add = true
        mapping[position.x] = {[position.y] = true}
      end

      if add then
        tile_index = tile_index + 1
        tiles[tile_index] = {
          position = position,
          name = tile_name
        }
      end
    end

    for _, entity in pairs(entities) do
      local rail_tiles = util.get_rail_tiles(entity)
      if rail_tiles then
        local entity_pos = entity.position
        for _, position in pairs(rail_tiles) do
          add_tile({x = position.x + entity_pos.x, y = position.y + entity_pos.y})
        end
      else
        local prototype = entity_prototypes[entity.name]
        if prototype then
          local EntityArea = area.load(prototype.collision_box):move(entity.position):ceil():expand(margin)

          for position in EntityArea:iterate() do
            add_tile(position)
          end
        end
      end
    end
  end

  blueprint.set_blueprint_tiles(tiles)
end
