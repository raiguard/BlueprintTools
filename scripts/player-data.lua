local constants = require("constants")

local buttons_gui = require("scripts.gui.buttons")
local import_string_gui = require("scripts.gui.import-string")
local library_shortcuts_gui = require("scripts.gui.library-shortcuts")

local player_data = {}

function player_data.init(player_index)
  --- @class PlayerTable
  storage.players[player_index] = {
    flags = {
      blueprint_buttons_shown = false,
      deconstruction_planner_buttons_shown = false,
      holding_temporary_item = false,
      setting_temporary_item = false,
      upgrade_planner_buttons_shown = false,
    },
    guis = {},
    set_tiles_settings = {
      fill_gaps = true,
      margin = 0,
      tile = "landfill",
    },
    settings = {},
  }
end

function player_data.update_settings(player, player_table)
  local mod_settings = player.mod_settings
  local settings = {}

  for internal, prototype in pairs(constants.settings) do
    settings[internal] = mod_settings[prototype].value
  end

  player_table.settings = settings
end

function player_data.refresh(player, player_table)
  player_data.update_settings(player, player_table)

  buttons_gui.refresh(player, player_table)
  import_string_gui.destroy(player)
  library_shortcuts_gui.refresh(player, player_table)

  -- If the tile does not exist
  if not prototypes.tile[player_table.set_tiles_settings.tile] then
    -- Set it to `nil`
    player_table.set_tiles_settings.tile = nil
  end
end

return player_data
