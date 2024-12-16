data:extend({
  { type = "custom-input", name = "bpt-import-string", key_sequence = "ALT + I", order = "a" },
  {
    type = "custom-input",
    name = "bpt-swap-wire-colors",
    key_sequence = "SHIFT + C",
    order = "aa",
  },
  {
    type = "custom-input",
    name = "bpt-set-tiles",
    key_sequence = "SHIFT + T",
    order = "ab",
  },
  {
    type = "custom-input",
    name = "bpt-quick-grid",
    key_sequence = "SHIFT + G",
    order = "ac",
  },
  {
    type = "custom-input",
    name = "bpt-configure",
    key_sequence = "SHIFT + B",
    order = "ad",
  },
  {
    type = "custom-input",
    name = "bpt-linked-confirm-gui",
    key_sequence = "",
    linked_game_control = "confirm-gui",
  },
  {
    type = "custom-input",
    name = "bpt-linked-clear-cursor",
    key_sequence = "",
    linked_game_control = "clear-cursor",
  },
  {
    type = "custom-input",
    name = "bpt-pipette-add",
    key_sequence = "SHIFT + mouse-button-3",
    include_selected_prototype = true,
  },
  {
    type = "custom-input",
    name = "bpt-pipette-remove",
    key_sequence = "CONTROL + mouse-button-3",
    include_selected_prototype = true,
  },
  {
    type = "custom-input",
    name = "bpt-pipette-downgrade",
    key_sequence = "SHIFT + ALT + mouse-button-3",
    include_selected_prototype = true,
  },
})
