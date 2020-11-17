local gui = require("__flib__.gui-beta")
local mod_gui = require("__core__.lualib.mod-gui")

local buttons_gui = {}

local function mod_gui_button(color, action)
  return {
    type = "sprite-button",
    style = "bpt_mod_gui_button_"..color,
    sprite = "bpt_"..action.."_white",
    tooltip = {"bpt-gui."..string.gsub(string.gsub(action, "bpt_", ""), "_", "-").."-tooltip"},
    elem_mods = {visible = false},
    actions = {
      on_click = {gui = "buttons", action = action}
    },
    ref = {action}
  }
end

function buttons_gui.refresh(player, player_table)
  local button_flow = mod_gui.get_button_flow(player)

  for _, button in pairs(player_table.guis.blueprint_buttons or {}) do
    button.destroy()
  end
  player_table.guis.blueprint_buttons = gui.build(button_flow, {
    -- mod_gui_button("blue", "flip_horizontally"),
    -- mod_gui_button("blue", "flip_vertically"),
    mod_gui_button("blue", "swap_wire_colors"),
    mod_gui_button("blue", "set_tiles"),
    mod_gui_button("blue", "quick_grid"),
    mod_gui_button("blue", "configure")
  })

  for _, button in pairs(player_table.guis.upgrade_planner_buttons or {}) do
    button.destroy()
  end
  player_table.guis.upgrade_planner_buttons = gui.build(button_flow, {
    mod_gui_button("green", "configure")
  })

  for _, button in pairs(player_table.guis.deconstruction_planner_buttons or {}) do
    button.destroy()
  end
  player_table.guis.deconstruction_planner_buttons = gui.build(button_flow, {
    mod_gui_button("red", "configure")
  })
end

function buttons_gui.show(player_table, button_type)
  for _, button in pairs(player_table.guis[button_type.."_buttons"]) do
    button.visible = true
  end
  player_table.flags[button_type.."_buttons_shown"] = true
end

function buttons_gui.hide(player_table, button_type)
  for _, button in pairs(player_table.guis[button_type.."_buttons"]) do
    button.visible = false
  end
  player_table.flags[button_type.."_buttons_shown"] = false
end

return buttons_gui