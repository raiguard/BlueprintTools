local event = require("__flib__.event")
local migration = require("__flib__.migration")

local buttons_gui = require("scripts.gui.buttons")
local global_data = require("scripts.global-data")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local util = require("scripts.util")

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

-- PLAYER

event.on_player_created(function(e)
  player_data.init(e.player_index)
  player_data.refresh(game.get_player(e.player_index), global.players[e.player_index])
end)

event.on_player_joined_game(function(e)

end)

event.on_player_left_game(function(e)

end)

event.on_player_removed(function(e)

end)

event.on_player_cursor_stack_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack

  local blueprint = util.get_blueprint(cursor_stack)
  local buttons_shown = player_table.flags.buttons_shown

  if blueprint then
    local is_setup = blueprint.is_blueprint_setup()
    if is_setup and not buttons_shown then
      buttons_gui.show(player_table)
    elseif not is_setup and buttons_shown then
      buttons_gui.hide(player_table)
    end
  elseif buttons_shown then
    buttons_gui.hide(player_table)
  end
end)