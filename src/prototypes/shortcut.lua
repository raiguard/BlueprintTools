-- Modify import string shortcut to show hotkey
local shortcut = data.raw["shortcut"]["import-string"]
if shortcut then
  shortcut.associated_control_input = "bpt-import-string"
end
