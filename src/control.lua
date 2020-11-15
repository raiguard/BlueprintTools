local event = require("__flib__.event")
local migration = require("__flib__.migration")

local buttons_gui = require("scripts.gui.buttons")
local global_data = require("scripts.global-data")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local util = require("scripts.util")

local quick_grid = require("scripts.processors.quick-grid")
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

  end
end)

-- CUSTOM INPUTS

-- event.register("bpt-flip-horizontally", function(e)
--   flip_blueprint(game.get_player(e.player_index), "horizontal")
-- end)

-- event.register("bpt-flip-vertically", function(e)
--   flip_blueprint(game.get_player(e.player_index), "vertical")
-- end)

event.register("bpt-swap-wire-colors", function(e)
  swap_wire_colors(game.get_player(e.player_index))
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

-- GUI

event.on_gui_click(function(e)
  local player = game.get_player(e.player_index)
  local tags = e.element.tags
  -- if tags.bpt_flip_horizontally then
  --   flip_blueprint(player, "horizontal")
  -- elseif tags.bpt_flip_vertically then
  --   flip_blueprint(player, "vertical")
  if tags.bpt_swap_wire_colors then
    swap_wire_colors(player)
  elseif tags.bpt_quick_grid then
    quick_grid(player)
  elseif tags.bpt_configure then
    player.opened = player.cursor_stack
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
end)
