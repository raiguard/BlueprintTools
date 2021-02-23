local clipboard = {}

function clipboard.create()
  local clipboards = game.create_inventory(2)
  clipboards.insert{name = "bpt-clipboard-book", count = 2}
  return clipboards
end

return clipboard
