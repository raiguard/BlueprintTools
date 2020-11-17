local gui = require("__flib__.gui-beta")

local set_tiles_gui = {}

function set_tiles_gui.build(player, player_table)
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = {"window"},
      actions = {
        on_closed = {gui = "set_tiles", action = "close"},
      },
      children = {
        {type = "flow", ref = {"titlebar_flow"}, children = {
          {type = "label", style = "frame_title", caption = {"controls.bpt-set-tiles"}, ignored_by_interaction = true},
          {type = "empty-widget", style = "flib_dialog_titlebar_drag_handle", ignored_by_interaction = true}
        }},
        {type = "frame", style = "inside_shallow_frame_with_padding", children = {
          {
            type = "choose-elem-button",
            style = "slot_button_in_shallow_frame",
            elem_type = "tile",
            elem_filters = {{filter = "blueprintable"}},
            actions = {
              on_elem_changed = {gui = "set_tiles", action = "update_tile"}
            }
          },
          {type = "flow", style_mods = {left_margin = 8}, direction = "vertical", children = {
            {
              type = "label",
              style = "caption_label",
              style_mods = {top_margin = -3, bottom_margin = -1},
              ref = {"tile_button"}
            },
            {
              type = "checkbox",
              caption = {"bpt-gui.fill-gaps"},
              state = true,
              actions = {
                on_checked_state_changed = {gui = "set_tiles", action = "update_fill_gaps"}
              }
            }
          }}
        }},
        {type = "flow", style = "dialog_buttons_horizontal_flow", children = {
          {
            type = "button",
            style = "back_button",
            caption = {"gui.cancel"},
            actions = {
              on_click = {gui = "set_tiles", action = "close"}
            }
          },
          {type = "empty-widget", style = "flib_dialog_footer_drag_handle", ref = {"footer_drag_handle"}},
          {
            type = "button",
            style = "confirm_button",
            caption = {"gui.confirm"},
            actions = {
              on_click = {gui = "set_tiles", action = "confirm"}
            }
          }
        }}
      }
    }
  })

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()

  player.opened = refs.window

  player_table.guis.set_tiles = {
    refs = refs
  }
end

function set_tiles_gui.destroy(player_table)
  local gui_data = player_table.guis.set_tiles
  gui_data.refs.window.destroy()
  player_table.guis.set_tiles = nil
end

function set_tiles_gui.handle_action(e, action)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if action.action == "close" then
    set_tiles_gui.destroy(player_table)
  elseif action.action == "confirm" then

  elseif action.action == "update_tile" then

  elseif action.action == "update_fill_gaps" then

  end
end

return set_tiles_gui