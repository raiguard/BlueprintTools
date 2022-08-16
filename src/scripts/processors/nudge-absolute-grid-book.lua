local util = require("scripts.util")

return function(player, delta)
  local book = player.cursor_stack
  local blueprint = util.get_blueprint(player.cursor_stack)

  if not book.valid_for_read or not book.is_blueprint_book then
    return
  elseif book.is_blueprint_book and not book.active_index then
    return
  elseif book.is_blueprint_book and not blueprint then
    return
  elseif not blueprint.blueprint_absolute_snapping then
    util.cursor_notification(player, {"message.bpt-blueprint-book-absolute-snapping-disabled"}, "utility/cannot_build")
    return
  end

  local blueprints = util.get_book_blueprints(book)
  local build_grid_size = util.get_blueprint_largest_build_grid_size(blueprints)

  for _, blueprint in pairs(blueprints) do
    if blueprint.blueprint_absolute_snapping then
      local position = blueprint.blueprint_position_relative_to_grid
      local size = blueprint.blueprint_snap_to_grid
      local new_position = {(position.x + delta.x * build_grid_size) % size.x, (position.y + delta.y * build_grid_size) % size.y}
      blueprint.blueprint_position_relative_to_grid = new_position
    end
  end
end
