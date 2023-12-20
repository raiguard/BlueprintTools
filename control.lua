local gui = require("__flib__.gui")
local migration = require("__flib__.migration")

local buttons_gui = require("scripts.gui.buttons")
local import_string_gui = require("scripts.gui.import-string")
local library_shortcuts_gui = require("scripts.gui.library-shortcuts")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local util = require("scripts.util")

local nudge_grid = require("scripts.processors.nudge-grid")
local nudge_absolute_grid = require("scripts.processors.nudge-absolute-grid")
local nudge_absolute_grid_book = require("scripts.processors.nudge-absolute-grid-book")
local quick_grid = require("scripts.processors.quick-grid")
local set_tiles_gui = require("scripts.gui.set-tiles")
local swap_wire_colors = require("scripts.processors.swap-wire-colors")

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

script.on_init(function()
  global.players = {}

  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

script.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    for i, player in pairs(game.players) do
      local player_table = global.players[i]
      player_data.refresh(player, player_table)
    end
  end
end)

-- CUSTOM INPUTS

script.on_event("bpt-import-string", function(e)
  local player = game.get_player(e.player_index)
  import_string_gui.build(player)
end)

script.on_event("bpt-swap-wire-colors", function(e)
  swap_wire_colors(game.get_player(e.player_index))
end)

script.on_event("bpt-set-tiles", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    local blueprint = util.get_blueprint(cursor_stack)
    if blueprint then
      set_tiles_gui.build(player, player_table)
    end
  end
end)

script.on_event("bpt-quick-grid", function(e)
  quick_grid(game.get_player(e.player_index))
end)

script.on_event("bpt-configure", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    local blueprint = util.get_blueprint(cursor_stack)
    if blueprint or (cursor_stack.is_upgrade_item or cursor_stack.is_deconstruction_item) then
      player.opened = cursor_stack
    end
  end
end)

script.on_event("bpt-nudge-grid-up", function(e)
  nudge_grid(game.get_player(e.player_index), { x = 0, y = 1 })
end)

script.on_event("bpt-nudge-grid-down", function(e)
  nudge_grid(game.get_player(e.player_index), { x = 0, y = -1 })
end)

script.on_event("bpt-nudge-grid-left", function(e)
  nudge_grid(game.get_player(e.player_index), { x = 1, y = 0 })
end)

script.on_event("bpt-nudge-grid-right", function(e)
  nudge_grid(game.get_player(e.player_index), { x = -1, y = 0 })
end)

-- Absolute grid nudging "reverses" directions compared to regular
-- grid nudging so it would make more sense for the player (otherwise
-- blueprint moves opposited direction to what the player presses).
script.on_event("bpt-nudge-absolute-grid-up", function(e)
  nudge_absolute_grid(game.get_player(e.player_index), { x = 0, y = -1 })
end)

script.on_event("bpt-nudge-absolute-grid-down", function(e)
  nudge_absolute_grid(game.get_player(e.player_index), { x = 0, y = 1 })
end)

script.on_event("bpt-nudge-absolute-grid-left", function(e)
  nudge_absolute_grid(game.get_player(e.player_index), { x = -1, y = 0 })
end)

script.on_event("bpt-nudge-absolute-grid-right", function(e)
  nudge_absolute_grid(game.get_player(e.player_index), { x = 1, y = 0 })
end)

-- Absolute grid nudging for all blueprints in a book.
script.on_event("bpt-nudge-absolute-grid-book-up", function(e)
  nudge_absolute_grid_book(game.get_player(e.player_index), { x = 0, y = -1 })
end)

script.on_event("bpt-nudge-absolute-grid-book-down", function(e)
  nudge_absolute_grid_book(game.get_player(e.player_index), { x = 0, y = 1 })
end)

script.on_event("bpt-nudge-absolute-grid-book-left", function(e)
  nudge_absolute_grid_book(game.get_player(e.player_index), { x = -1, y = 0 })
end)

script.on_event("bpt-nudge-absolute-grid-book-right", function(e)
  nudge_absolute_grid_book(game.get_player(e.player_index), { x = 1, y = 0 })
end)

script.on_event("bpt-linked-confirm-gui", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.set_tiles
  if gui_data and gui_data.refs.confirm_button.enabled then
    set_tiles_gui.handle_action(e, { action = "confirm" })
    player.play_sound({ path = "utility/confirm" })
  end
end)

script.on_event("bpt-linked-clear-cursor", function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  if player_table.flags.holding_temporary_item and cursor_stack.valid_for_read then
    local item_type = cursor_stack.type
    if item_type == "blueprint" and not cursor_stack.is_blueprint_setup() then
      cursor_stack.clear()
    elseif item_type == "blueprint-book" or item_type == "upgrade-item" or item_type == "deconstruction-item" then
      cursor_stack.clear()
    end
  end
end)

-- GUI

gui.hook_events(function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  local action = gui.read_action(e)

  if action then
    if action.gui == "buttons" then
      if action.action == "swap_wire_colors" then
        swap_wire_colors(player)
      elseif action.action == "set_tiles" then
        set_tiles_gui.build(player, player_table)
      elseif action.action == "quick_grid" then
        quick_grid(player)
      elseif action.action == "configure" then
        player.opened = player.cursor_stack
      end
    elseif action.gui == "set_tiles" then
      set_tiles_gui.handle_action(e, action)
    elseif action.gui == "library_shortcuts" then
      library_shortcuts_gui.handle_action(player, player_table, action)
    elseif action.gui == "import_string" then
      import_string_gui.handle_action(player, action)
    end
  end
end)

-- PLAYER

script.on_event(defines.events.on_player_created, function(e)
  player_data.init(e.player_index)
  player_data.refresh(game.get_player(e.player_index), global.players[e.player_index])
end)

script.on_event(defines.events.on_player_removed, function(e)
  global.players[e.player_index] = nil
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack

  if player_table.flags.setting_temporary_item then
    player_table.flags.setting_temporary_item = false
  elseif player_table.flags.holding_temporary_item then
    player_table.flags.holding_temporary_item = false
  end

  local blueprint = util.get_blueprint(cursor_stack)
  local blueprint_buttons_shown = player_table.flags.blueprint_buttons_shown

  if blueprint and not blueprint_buttons_shown then
    buttons_gui.show(player_table, "blueprint")
  elseif not blueprint and blueprint_buttons_shown then
    buttons_gui.hide(player_table, "blueprint")
  end

  if cursor_stack.is_upgrade_item then
    buttons_gui.show(player_table, "upgrade_planner")
  elseif player_table.flags.upgrade_planner_buttons_shown then
    buttons_gui.hide(player_table, "upgrade_planner")
  end

  if cursor_stack.is_deconstruction_item then
    buttons_gui.show(player_table, "deconstruction_planner")
  elseif player_table.flags.deconstruction_planner_buttons_shown then
    buttons_gui.hide(player_table, "deconstruction_planner")
  end

  -- if the set tiles GUI is open and the cursor stack changes in any way, close it
  if player_table.guis.set_tiles then
    set_tiles_gui.destroy(player_table)
  end
end)

-- SETTINGS

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if string.sub(e.setting, 1, 4) == "bpt-" then
    local player = game.get_player(e.player_index)
    if not player then
      return
    end
    local player_table = global.players[e.player_index]
    player_data.update_settings(player, player_table)
    if e.setting == "bpt-show-library-shortcuts" then
      library_shortcuts_gui.refresh(player, player_table)
    else
      buttons_gui.refresh(player, player_table)
      local flags = player_table.flags
      if flags.blueprint_buttons_shown then
        buttons_gui.show(player_table, "blueprint")
      end
      if flags.upgrade_planner_buttons_shown then
        buttons_gui.show(player_table, "upgrade_planner")
      end
      if flags.deconstruction_planner_buttons_shown then
        buttons_gui.show(player_table, "deconstruction_planner")
      end
    end
  end
end)
