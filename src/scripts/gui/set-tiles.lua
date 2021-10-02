local gui = require("__flib__.gui-beta")

local set_tiles = require("scripts.processors.set-tiles")

local set_tiles_gui = {}

function set_tiles_gui.build(player, player_table)
  local settings = player_table.set_tiles_settings
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      caption = {"controls.bpt-set-tiles"},
      ref = {"window"},
      actions = {
        on_closed = {gui = "set_tiles", action = "close"},
      },
      children = {
        {type = "frame", style = "inside_shallow_frame_with_padding", children = {
          {
            type = "choose-elem-button",
            style = "slot_button_in_shallow_frame",
            elem_type = "tile",
            tile = settings.tile,
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
              caption = {"gui.bpt-fill-gaps"},
              tooltip = {"gui.bpt-fill-gaps-description"},
              state = settings.fill_gaps,
              ref = {"fill_gaps_checkbox"}
            },
            {type = "flow", style_mods = {vertical_align = "center"}, ref = {"margin_flow"}, children = {
              {
                type = "label",
                style_mods = {right_margin = 8},
                caption = {"gui.bpt-margin"},
                tooltip = {"gui.bpt-margin-description"}
              },
              {
                type = "textfield",
                style_mods = {width = 50, horizontal_align = "center"},
                text = tostring(settings.margin),
                numeric = settings.margin,
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
            ref = {"confirm_button"},
            actions = {
              on_click = {gui = "set_tiles", action = "confirm"}
            }
          }
        }}
      }
    }
  })

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

function set_tiles_gui.handle_action(e, msg)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.set_tiles
  local refs = gui_data.refs

  if msg.action == "close" then
    set_tiles_gui.destroy(player_table)
  elseif msg.action == "confirm" then
    local tile_name = refs.tile_button.elem_value
    if tile_name then
      -- Save settings
      local settings = player_table.set_tiles_settings
      settings.tile = tile_name
      settings.fill_gaps = refs.fill_gaps_checkbox.state
      settings.margin = tonumber(refs.margin_textfield.text)

      -- Modify the blueprint
      set_tiles(player, tile_name, settings.fill_gaps, settings.margin)

      -- Destroy the GUI
      set_tiles_gui.destroy(player_table)
    end
  elseif msg.action == "update_tile" then
    local tile_name = refs.tile_button.elem_value
    if tile_name then
      refs.confirm_button.enabled = true
    else
      refs.confirm_button.enabled = false
    end
  end
end

return set_tiles_gui
