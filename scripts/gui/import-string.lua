local gui = require("gui")

local util = require("scripts.util")

local import_string_gui = {}

function import_string_gui.build(player)
  import_string_gui.destroy(player)

  local frame = gui.add(player.gui.screen, {
    type = "frame",
    name = "bpt_import_string_frame",
    direction = "vertical",
    caption = { "gui-blueprint-library.import-string" },
    actions = {
      on_closed = { gui = "import_string", action = "close" },
    },
    ref = { "window" },
    {
      type = "text-box",
      name = "textbox",
      style_mods = { width = 400, height = 250 },
      elem_mods = { word_wrap = true },
      ref = { "textbox" },
    },
    {
      type = "flow",
      name = "footer_flow",
      style = "dialog_buttons_horizontal_flow",
      ref = { "footer_flow" },
      {
        type = "button",
        style = "back_button",
        caption = { "gui.cancel" },
        actions = {
          on_click = { gui = "import_string", action = "close" },
        },
      },
      { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ignored_by_interaction = true },
      {
        type = "button",
        style = "confirm_button",
        caption = { "gui-blueprint-library.import" },
        actions = {
          on_click = { gui = "import_string", action = "import" },
        },
      },
    },
  })

  frame.force_auto_center()
  frame.footer_flow.drag_target = frame
  frame.textbox.focus()
  player.opened = frame
end

function import_string_gui.destroy(player)
  local frame = player.gui.screen.bpt_string_import_frame
  if frame and frame.valid then
    if player.opened == frame then
      player.opened = nil
    end
    frame.destroy()
  end
end

function import_string_gui.handle_action(player, action)
  local frame = player.gui.screen.bpt_import_string_frame
  if not frame or not frame.valid then
    return
  end
  if action.action == "close" then
    frame.destroy()
  elseif action.action == "import" then
    if player.clear_cursor() then
      local result = player.cursor_stack.import_stack(frame.textbox.text)
      if result == 0 then
        local cursor_stack = player.cursor_stack
        if cursor_stack.valid_for_read then
          util.cursor_notification(player, { "string-import-successful", cursor_stack.prototype.localised_name })
        else
          util.cursor_notification(player, { "string-import-produced-no-item" }, "utility/cannot_build")
        end
        frame.destroy()
      else
        util.cursor_notification(player, { "failed-to-import-string", "" }, "utility/cannot_build")
      end
    else
      util.cursor_notification(player, { "message.bpt-unable-to-clear-cursor" }, "utility/cannot_build")
    end
  end
end

return import_string_gui
