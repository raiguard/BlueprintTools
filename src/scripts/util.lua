local util = {}

-- get blueprint from cursor stack (if there is one)
function util.get_blueprint(item_stack)
  if not (item_stack and item_stack.valid_for_read) then return end
  if item_stack.is_blueprint then
    return item_stack
  elseif item_stack.is_blueprint_book and item_stack.active_index then
    local inventory = item_stack.get_inventory(defines.inventory.item_main)
    if inventory.is_empty() then return end
    return util.get_blueprint(inventory[item_stack.active_index])
  end
end

-- collisions for diagonal and curved rails are hardcoded
-- each table is a direction -> colliding tiles mapping, relative to the centerpoint of the entity
local rail_tiles = {
  ["curved-rail"] = {
    [0] = {
      {x = -3, y = -3},
      {x = -3, y = -2},
      {x = -2, y = -4},
      {x = -2, y = -3},
      {x = -2, y = -2},
      {x = -2, y = -1},
      {x = -1, y = -3},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 0, y = 2},
      {x = 0, y = 3},
      {x = 1, y = 0},
      {x = 1, y = 1},
      {x = 1, y = 2},
      {x = 1, y = 3}
    },
    [1] = {
      {x = -2, y = 0},
      {x = -2, y = 1},
      {x = -2, y = 2},
      {x = -2, y = 3},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = -1, y = 2},
      {x = -1, y = 3},
      {x = 0, y = -3},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 1, y = -4},
      {x = 1, y = -3},
      {x = 1, y = -2},
      {x = 1, y = -1},
      {x = 2, y = -3},
      {x = 2, y = -2}
    },
    [2] = {
      {x = -4, y = 0},
      {x = -4, y = 1},
      {x = -3, y = 0},
      {x = -3, y = 1},
      {x = -2, y = 0},
      {x = -2, y = 1},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 1, y = -3},
      {x = 1, y = -2},
      {x = 1, y = -1},
      {x = 1, y = 0},
      {x = 2, y = -3},
      {x = 2, y = -2},
      {x = 2, y = -1},
      {x = 3, y = -2}
    },
    [3] = {
      {x = -4, y = -2},
      {x = -4, y = -1},
      {x = -3, y = -2},
      {x = -3, y = -1},
      {x = -2, y = -2},
      {x = -2, y = -1},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 1, y = -1},
      {x = 1, y = 0},
      {x = 1, y = 1},
      {x = 1, y = 2},
      {x = 2, y = 0},
      {x = 2, y = 1},
      {x = 2, y = 2},
      {x = 3, y = 1}
    },
    [4] = {
      {x = -2, y = -4},
      {x = -2, y = -3},
      {x = -2, y = -2},
      {x = -2, y = -1},
      {x = -1, y = -4},
      {x = -1, y = -3},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 0, y = 2},
      {x = 1, y = 0},
      {x = 1, y = 1},
      {x = 1, y = 2},
      {x = 1, y = 3},
      {x = 2, y = 1},
      {x = 2, y = 2}
    },
    [5] = {
      {x = -3, y = 1},
      {x = -3, y = 2},
      {x = -2, y = 0},
      {x = -2, y = 1},
      {x = -2, y = 2},
      {x = -2, y = 3},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = -1, y = 2},
      {x = 0, y = -4},
      {x = 0, y = -3},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 1, y = -4},
      {x = 1, y = -3},
      {x = 1, y = -2},
      {x = 1, y = -1}
    },
    [6] = {
      {x = -4, y = 1},
      {x = -3, y = 0},
      {x = -3, y = 1},
      {x = -3, y = 2},
      {x = -2, y = -1},
      {x = -2, y = 0},
      {x = -2, y = 1},
      {x = -2, y = 2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 1, y = -2},
      {x = 1, y = -1},
      {x = 2, y = -2},
      {x = 2, y = -1},
      {x = 3, y = -2},
      {x = 3, y = -1}
    },
    [7] = {
      {x = -4, y = -2},
      {x = -3, y = -3},
      {x = -3, y = -2},
      {x = -3, y = -1},
      {x = -2, y = -3},
      {x = -2, y = -2},
      {x = -2, y = -1},
      {x = -2, y = 0},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 1, y = 0},
      {x = 1, y = 1},
      {x = 2, y = 0},
      {x = 2, y = 1},
      {x = 3, y = 0},
      {x = 3, y = 1}
    }
  },
  ["straight-rail"] = {
    [1] = {
      {x = -1, y = -1},
      {x = 0, y = -2},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 1, y = -1}
    },
    [3] = {
      {x = -1, y = 0},
      {x = 0, y = -1},
      {x = 0, y = 0},
      {x = 0, y = 1},
      {x = 1, y = 0}
    },
    [5] = {
      {x = -2, y = 0},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = -1, y = 1},
      {x = 0, y = 0}
    },
    [7] = {
      {x = -2, y = -1},
      {x = -1, y = -2},
      {x = -1, y = -1},
      {x = -1, y = 0},
      {x = 0, y = -1}
    }
  }
}

function util.get_rail_tiles(entity)
  local category = rail_tiles[game.entity_prototypes[entity.name].type]
  if not category then return end

  return category[entity.direction or 0]
end

return util
