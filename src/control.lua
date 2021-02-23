local event = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local migration = require("__flib__.migration")

local constants = require("constants")

local buttons_gui = require("scripts.gui.buttons")
local global_data = require("scripts.global-data")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local util = require("scripts.util")

local quick_grid = require("scripts.processors.quick-grid")
local set_tiles_gui = require("scripts.gui.set-tiles")
local swap_wire_colors = require("scripts.processors.swap-wire-colors")

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global_data.init()

  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

event.on_load(function()

end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    for i, player in pairs(game.players) do
      local player_table = global.players[i]
      player_data.refresh(player, player_table)
    end
  end
end)

-- CUSTOM INPUTS

event.register("bpt-swap-wire-colors", function(e)
  swap_wire_colors(game.get_player(e.player_index))
end)

event.register("bpt-set-tiles", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    local blueprint = util.get_blueprint(cursor_stack)
    if blueprint and blueprint.is_blueprint_setup() then
      set_tiles_gui.build(player, player_table)
    end
  end
end)

event.register("bpt-quick-grid", function(e)
  quick_grid(game.get_player(e.player_index))
end)

event.register("bpt-configure", function(e)
  local player = game.get_player(e.player_index)
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    local blueprint = util.get_blueprint(cursor_stack)
    if
      (blueprint and blueprint.is_blueprint_setup())
      or (cursor_stack.is_upgrade_item or cursor_stack.is_deconstruction_item)
    then
      player.opened = cursor_stack
    end
  end
end)

event.register({"bpt-activate-deconstruction-clipboard", "bpt-activate-upgrade-clipboard"}, function(e)
  local _, _, type = string.find(e.input_name, "bpt%-activate%-(.*)%-clipboard")

  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  local cursor_stack = player.cursor_stack
  if cursor_stack then
    local clipboard_book = player_table.clipboards[constants.clipboard_indices[type]]
    local clipboard_inventory = clipboard_book.get_inventory(defines.inventory.item_main)
    if not clipboard_inventory.is_empty() and player.clear_cursor() then
      cursor_stack.set_stack(clipboard_book)
    end
  end
end)

event.register("bpt-linked-confirm-gui", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.set_tiles
  if gui_data and gui_data.refs.confirm_button.enabled then
    set_tiles_gui.handle_action(e, {action = "confirm"})
    player.play_sound{path = "utility/confirm"}
  end
end)

-- event.register({"bpt-linked-cycle-blueprint-backwards", "bpt-linked-cycle-blueprint-forwards"}, function(e)
--   local direction = e.input_name == "bpt-linked-cycle-blueprint-backwards" and -1 or 1
-- end)

event.register("bpt-linked-clear-cursor", function(e)
end)

-- GUI

gui.hook_events(function(e)
  local player = game.get_player(e.player_index)
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
    end
  end
end)

-- PLAYER

event.on_player_created(function(e)
  player_data.init(e.player_index)
  player_data.refresh(game.get_player(e.player_index), global.players[e.player_index])
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_player_cursor_stack_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack

  local blueprint = util.get_blueprint(cursor_stack)
  local blueprint_buttons_shown = player_table.flags.blueprint_buttons_shown

  if blueprint then
    local is_setup = blueprint.is_blueprint_setup()
    if is_setup and not blueprint_buttons_shown then
      buttons_gui.show(player_table, "blueprint")
    elseif not is_setup and blueprint_buttons_shown then
      buttons_gui.hide(player_table, "blueprint")
    end
  elseif blueprint_buttons_shown then
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
