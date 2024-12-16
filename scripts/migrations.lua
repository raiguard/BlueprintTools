return {
  ["1.2.0"] = function()
    for _, player_table in pairs(storage.players) do
      player_table.set_tiles_settings = {
        fill_gaps = true,
        margin = 0,
        tile = "landfill",
      }
    end
  end,
  ["1.3.0"] = function()
    for _, player_table in pairs(storage.players) do
      player_table.holding_temporary_item = false
      player_table.setting_temporary_item = false
    end
  end,
}
