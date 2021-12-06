return {
  ["1.2.0"] = function()
    for _, player_table in pairs(global.players) do
      player_table.set_tiles_settings = {
        fill_gaps = true,
        margin = 0,
        tile = "landfill",
      }
    end
  end,
}
