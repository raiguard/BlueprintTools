local buttons_gui = require("scripts.gui.buttons")

local player_data = {}

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      buttons_shown = false
    },
    guis = {},
    settings = {}
  }
end

function player_data.refresh(player, player_table)
  buttons_gui.refresh(player, player_table)
end

return player_data