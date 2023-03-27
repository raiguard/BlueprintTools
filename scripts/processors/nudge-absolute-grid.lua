local util = require("scripts.util")

return function(player, delta)
  ---@type LuaItemStack
  local blueprint = util.get_blueprint(player.cursor_stack)

  if not blueprint then
    return
  end

  if not blueprint.blueprint_absolute_snapping then
    util.cursor_notification(player, { "message.bpt-blueprint-absolute-snapping-disabled" }, "utility/cannot_build")
    return
  end

  local position = blueprint.blueprint_position_relative_to_grid
  local size = blueprint.blueprint_snap_to_grid
  local build_grid_size = util.get_blueprint_largest_build_grid_size({ blueprint })
  local new_position =
    { (position.x + delta.x * build_grid_size) % size.x, (position.y + delta.y * build_grid_size) % size.y }

  blueprint.blueprint_position_relative_to_grid = new_position
end
