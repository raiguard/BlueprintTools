local constants = require("constants")

local styles = data.raw["gui-style"].default

-- BUTTON STYLES

styles.bpt_mod_gui_button_blue = {
  type = "button_style",
  parent = "tool_button_blue",
  size = 40,
  padding = 8,
}

styles.bpt_mod_gui_button_red = {
  type = "button_style",
  parent = "flib_tool_button_dark_red",
  size = 40,
  padding = 8,
}

styles.bpt_mod_gui_button_green = {
  type = "button_style",
  parent = "tool_button_green",
  size = 40,
  padding = 8,
}

-- Generate styles for library shortcuts
for _, prototype_name in pairs(constants.library_shortcut_prototypes) do
  local prototype = data.raw["shortcut"][prototype_name]
  if prototype then
    local style = prototype.style and ("_" .. prototype.style) or ""
    styles["bpt_shortcut_button_" .. prototype_name] = {
      type = "button_style",
      parent = "shortcut_bar_button" .. style,
    }
  end
end
