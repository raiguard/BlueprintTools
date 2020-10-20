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

return util