local constants = require("constants")

local util = {}

--- Get the current blueprint from the item stack, if it exists and is set up.
--- @param item_stack LuaItemStack
--- @return LuaItemStack|nil
function util.get_blueprint(item_stack)
  if not item_stack or not item_stack.valid_for_read then
    return
  end
  local blueprint
  if item_stack.is_blueprint then
    blueprint = item_stack
  elseif item_stack.is_blueprint_book and item_stack.active_index then
    local inventory = item_stack.get_inventory(defines.inventory.item_main)
    if inventory.is_empty() or item_stack.active_index > #inventory then
      return
    end
    blueprint = util.get_blueprint(inventory[item_stack.active_index])
  end

  if blueprint and blueprint.is_blueprint_setup() then
    return blueprint
  end
end

function util.get_rail_tiles(entity)
  local category = constants.rail_tiles[game.entity_prototypes[entity.name].type]
  if not category then
    return
  end

  return category[entity.direction or 0]
end

return util
