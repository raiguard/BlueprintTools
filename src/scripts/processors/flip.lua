-- full disclosure: this code was basically stolen from Blueprint Extensions
-- it's MIT as well, so that's perfectly legal! >:D

local util = require("scripts.util")

local flip_metadata = {
  translations = {
    horizontal = {
      axis = "x",
      rail_offset = 9,
      default_offset = 16,
      signals = {
        [0] = 4,
        [1] = 3,
        [3] = 1,
        [4] = 0,
        [5] = 7,
        [7] = 5
      },
      train_stops = {
        [0] = 4,
        [4] = 1,
      },
    },
    vertical = {
      axis = "y",
      rail_offset = 13,
      default_offset = 12,
      signals = {
        [1] = 7,
        [2] = 6,
        [3] = 5,
        [5] = 3,
        [6] = 2,
        [7] = 1
      },
      train_stops = {
        [2] = 6,
        [6] = 2
      },
    },
  },
  sides = {
    left = 'right',
    right = 'left'
  }
}

local function flip_blueprint(player, flip_direction)
  local blueprint = util.get_blueprint(player.cursor_stack)
  if not blueprint then return end

  local metadata = flip_metadata.translations[flip_direction]
  local axis = metadata.axis
  local entities = blueprint.get_blueprint_entities()

  if entities then
    for _, entity in pairs(entities) do
      local prototype = game.entity_prototypes[entity.name]
      local entity_type = prototype.type
      local direction = entity.direction or 0

      -- direction
      if entity_type == "curved-rail" then
        entity.direction = (metadata.rail_offset - direction) % 8
      elseif entity_type == "storage-tank" then
        if direction == 2 or direction == 6 then
          entity.direction = 4
        else
          entity.direction = 2
        end
      elseif entity_type == "rail-signal" or entity_type == "rail-chain-signal" then
        local new_direction = metadata.signals[direction]
        if new_direction then
          entity.direction = new_direction
        end
      elseif entity_type == "train-stop" then
        local new_direction = metadata.train_stops[direction]
        if new_direction then
          entity.direction = new_direction
        end
      else
        entity.direction = (metadata.default_offset - direction) % 8
      end

      -- position
      entity.position[axis] = -entity.position[axis]
      if entity.drop_position then
        entity.drop_position[axis] = -entity.drop_position[axis]
      end
      if entity.pickup_position then
        entity.pickup_position[axis] = -entity.pickup_position[axis]
      end

      if flip_metadata.sides[entity.input_priority] then
        entity.input_priority = flip_metadata.sides[entity.input_priority]
      end
      if flip_metadata.sides[entity.output_priority] then
        entity.output_priority = flip_metadata.sides[entity.output_priority]
      end
    end

    blueprint.set_blueprint_entities(entities)
  end
end

return flip_blueprint