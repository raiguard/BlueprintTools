local gui = require("__flib__.gui")

local constants = require("constants")
local import_string_gui = require("scripts.gui.import-string")
local util = require("scripts.util")

local library_shortcuts_gui = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function library_shortcuts_gui.refresh(player, player_table)
  local frame = player.gui.relative.bpt_library_shortcuts_frame
  if frame and frame.valid then
    frame.destroy()
  end

  if not player_table.settings.show_library_shortcuts then
    return
  end

  local buttons = {}
  for _, prototype_name in pairs(constants.library_shortcut_prototypes) do
    local prototype = game.shortcut_prototypes[prototype_name]
    if prototype then
      local tooltip = prototype.localised_name
      if prototype.associated_control_input then
        tooltip = { "", tooltip, " (", { "gui.bpt-shortcut-" .. prototype_name .. "-control" }, ")" }
      end
      table.insert(buttons, {
        type = "sprite-button",
        style = "bpt_shortcut_button_" .. prototype_name,
        sprite = "bpt_shortcut_sprite_" .. prototype_name,
        tooltip = tooltip,
        actions = {
          on_click = {
            gui = "library_shortcuts",
            action = prototype.action,
            item_to_spawn = prototype.item_to_spawn and prototype.item_to_spawn.name or nil,
          },
        },
      })
    end
  end

  gui.add(player.gui.relative, {
    type = "frame",
    name = "bpt_library_shortcuts_frame",
    style = "quick_bar_window_frame",
    {
      type = "frame",
      style = "inside_deep_frame",
      direction = "vertical",
      children = buttons,
    },
    --- @type GuiAnchor
    anchor = {
      gui = defines.relative_gui_type.blueprint_library_gui,
      position = defines.relative_gui_position.right,
    },
  })
end

--- @param player LuaPlayer
function library_shortcuts_gui.handle_action(player, player_table, action)
  if action.action == "spawn-item" then
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid and player.clear_cursor() then
      cursor_stack.set_stack({ type = "item", name = action.item_to_spawn, count = 1 })
      -- The event will not fire until the next tick
      player_table.flags.setting_temporary_item = true
      player_table.flags.holding_temporary_item = true
    else
      util.cursor_notification(player, { "message.bpt-unable-to-clear-cursor" }, "utility/cannot_build")
    end
  elseif action.action == "import-string" then
    import_string_gui.build(player)
  end
end

return library_shortcuts_gui
