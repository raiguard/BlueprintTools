local constants = require("constants")

local util = {}

-- get blueprint from cursor stack (if there is one)
function util.get_blueprint(item_stack)
  if not (item_stack and item_stack.valid_for_read) then return end
  if item_stack.is_blueprint then
    return item_stack
  elseif item_stack.is_blueprint_book and item_stack.active_index then
    local inventory = item_stack.get_inventory(defines.inventory.item_main)
    if inventory.is_empty() or item_stack.stack_index > #inventory then return end
    return util.get_blueprint(inventory[item_stack.active_index])
  end
end

function util.get_rail_tiles(entity)
  local category = constants.rail_tiles[game.entity_prototypes[entity.name].type]
  if not category then return end

  return category[entity.direction or 0]
end

util.curved_rail_grid_sizes = {
  {left_top = {x = -2, y = -4}, right_bottom = {x = 2, y = 4}},
  {left_top = {x = -4, y = -2}, right_bottom = {x = 4, y = 2}}
}

return util
