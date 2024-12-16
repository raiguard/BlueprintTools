local constants = require("constants")

local button_icons_file = "__BlueprintTools__/graphics/button-icons.png"

data:extend({
  {
    type = "sprite",
    name = "bpt_flip_horizontally_white",
    filename = button_icons_file,
    y = 0,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "bpt_flip_vertically_white",
    filename = button_icons_file,
    y = 32,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "bpt_swap_wire_colors_white",
    filename = button_icons_file,
    y = 64,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "bpt_set_tiles_white",
    filename = button_icons_file,
    y = 96,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "bpt_quick_grid_white",
    filename = button_icons_file,
    y = 128,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
  {
    type = "sprite",
    name = "bpt_configure_white",
    filename = button_icons_file,
    y = 160,
    size = 32,
    mipmap_count = 2,
    flags = { "icon" },
  },
})

-- Generate sprites for library shortcuts
for _, prototype_name in pairs(constants.library_shortcut_prototypes) do
  local prototype = data.raw.shortcut[prototype_name]
  data:extend({
    {
      type = "sprite",
      name = "bpt_shortcut_sprite_" .. prototype_name,
      filename = prototype.icon,
      size = prototype.icon_size,
      flags = { "gui-icon" },
    },
  })
end
