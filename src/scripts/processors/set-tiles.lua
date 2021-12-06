local area = require("__flib__.area")
local table = require("__flib__.table")

local util = require("scripts.util")

return function(player, tile_name, fill_gaps, margin)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then
    return
  end

  local entities = blueprint.get_blueprint_entities() or {}
  local tiles = blueprint.get_blueprint_tiles() or {}
  local entity_prototypes = game.entity_prototypes

  local output_tiles = {}
  local tile_index = 0

  local first_obj = entities[1] or tiles[1]

  if fill_gaps then
    local TileArea = area.load(area.from_position(first_obj.position))

    -- iterate entities to calculate needed grid size
    for _, entity in pairs(entities) do
      local prototype = entity_prototypes[entity.name]
      if prototype then
        local box = (
            prototype.type == "curved-rail"
              and table.deep_copy(util.curved_rail_grid_sizes[math.floor((entity.direction or 0) / 2) % 2 + 1])
            or prototype.collision_box
          )
        TileArea:expand_to_contain_area(area.move(box, entity.position))
      end
    end
    -- and tiles
    for _, tile in pairs(tiles) do
      local box = {
        left_top = { x = tile.position.x, y = tile.position.y },
        right_bottom = { x = tile.position.x + 1, y = tile.position.y + 1 },
      }
      TileArea:expand_to_contain_area(box)
    end

    -- ceil to outside edges and add a margin
    TileArea:ceil():expand(margin)

    -- for the purpose of this function, we don't care about any pre-existing tiles - we will replace all of them
    for position in TileArea:iterate() do
      tile_index = tile_index + 1
      output_tiles[tile_index] = {
        position = position,
        name = tile_name,
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
        mapping[position.x] = { [position.y] = true }
      end

      if add then
        tile_index = tile_index + 1
        output_tiles[tile_index] = {
          position = position,
          name = tile_name,
        }
      end
    end

    for _, entity in pairs(entities) do
      local rail_tiles = util.get_rail_tiles(entity)
      if rail_tiles then
        local entity_pos = entity.position
        for _, src_position in pairs(rail_tiles) do
          for position in area.load(area.from_position(src_position, true)):expand(margin):iterate() do
            add_tile({ x = position.x + entity_pos.x, y = position.y + entity_pos.y })
          end
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
    for _, tile in pairs(tiles) do
      add_tile(tile.position)
    end
  end

  blueprint.set_blueprint_tiles(output_tiles)
end
