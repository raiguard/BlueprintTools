local flib_bounding_box = require("__flib__.bounding-box")
local table = require("__flib__.table")

local constants = require("constants")
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
    local box = flib_bounding_box.from_position(first_obj.position)

    -- iterate entities to calculate needed grid size
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
    -- and tiles
    for _, tile in pairs(tiles) do
      box = flib_bounding_box.expand_to_contain_box(box, {
        left_top = { x = tile.position.x, y = tile.position.y },
        right_bottom = { x = tile.position.x + 1, y = tile.position.y + 1 },
      })
    end

    -- ceil to outside edges and add a margin
    box = flib_bounding_box.resize(flib_bounding_box.ceil(box), margin)

    -- for the purpose of this function, we don't care about any pre-existing tiles - we will replace all of them
    util.for_each_position(box, function(position)
      tile_index = tile_index + 1
      output_tiles[tile_index] = {
        position = position,
        name = tile_name,
      }
    end)
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
          util.for_each_position(
            flib_bounding_box.resize(flib_bounding_box.from_position(src_position, true), margin),
            function(position)
              add_tile({ x = position.x + entity_pos.x, y = position.y + entity_pos.y })
            end
          )
        end
      else
        local prototype = entity_prototypes[entity.name]
        if prototype then
          util.for_each_position(
            flib_bounding_box.resize(
              flib_bounding_box.ceil(flib_bounding_box.move(prototype.collision_box, entity.position)),
              margin
            ),
            function(position)
              add_tile(position)
            end
          )
        end
      end
    end
    for _, tile in pairs(tiles) do
      add_tile(tile.position)
    end
  end

  blueprint.set_blueprint_tiles(output_tiles)
end
