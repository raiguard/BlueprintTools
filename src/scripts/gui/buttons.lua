local mod_gui = require("__core__.lualib.mod-gui")

local buttons_gui = {}

function buttons_gui.refresh(player, player_table)
  local button_flow = mod_gui.get_button_flow(player)

  for _, button in pairs(player_table.guis.buttons or {}) do
    button.destroy()
  end

  local flip_horizontal = button_flow.add{
    type = "sprite-button",
    style = "bpt_mod_gui_button_blue",
    sprite = "bpt_flip_vertical_white"
  }
  flip_horizontal.visible = false
  local flip_vertical = button_flow.add{
    type = "sprite-button",
    style = "bpt_mod_gui_button_blue",
    sprite = "bpt_flip_horizontal_white"
  }
  flip_vertical.visible = false

  player_table.guis.buttons = {
    flip_vertical = flip_vertical,
    flip_horizontal = flip_horizontal
  }
end

return buttons_gui