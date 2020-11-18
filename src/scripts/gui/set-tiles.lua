local gui = require("__flib__.gui-beta")

local set_tiles = require("scripts.processors.set-tiles")

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
            },
            ref = {"tile_button"}
          },
          {type = "line", style_mods = {left_margin = 8, vertically_stretchable = true}, direction = "vertical"},
          {type = "flow", style_mods = {left_margin = 8}, direction = "vertical", children = {
            {
              type = "checkbox",
              caption = {"bpt-gui.fill-gaps"},
              tooltip = {"bpt-gui.fill-gaps-description"},
              state = true,
              ref = {"fill_gaps_checkbox"}
            },
            {type = "flow", style_mods = {vertical_align = "center"}, ref = {"margin_flow"}, children = {
              {type = "label", style_mods = {right_margin = 8}, caption = {"bpt-gui.margin"}, tooltip = {"bpt-gui.margin-description"}},
              {
                type = "textfield",
                style_mods = {width = 50, horizontal_align = "center"},
                text = "0",
                ref = {"margin_textfield"}
              }
            }}
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
          {
            type = "empty-widget",
            style = "flib_dialog_footer_drag_handle",
            style_mods = {minimal_width = 24},
            ref = {"footer_drag_handle"}
          },
          {
            type = "button",
            style = "confirm_button",
            caption = {"gui.confirm"},
            elem_mods = {enabled = false},
            ref = {"confirm_button"},
            actions = {
              on_click = {gui = "set_tiles", action = "confirm"}
            }
          }
        }}
      }
    }
  })

  refs.titlebar_flow.drag_target = refs.window
  refs.footer_drag_handle.drag_target = refs.window
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
  local gui_data = player_table.guis.set_tiles
  local refs = gui_data.refs

  if action.action == "close" then
    set_tiles_gui.destroy(player_table)
  elseif action.action == "confirm" then
    local tile_name = refs.tile_button.elem_value
    if tile_name then
      set_tiles(player, tile_name, refs.fill_gaps_checkbox.state)
      set_tiles_gui.destroy(player_table)
    end
  elseif action.action == "update_tile" then
    local tile_name = refs.tile_button.elem_value
    if tile_name then
      refs.confirm_button.enabled = true
    else
      refs.confirm_button.enabled = false
    end
  end
end

return set_tiles_gui