local util = require("scripts.util")

---@param index uint
---@return LuaItemStack?
local function get_cursor_stack(index)
	local player = game.get_player(index) --[[@as LuaPlayer]]
	local cursor = player.cursor_stack
	if not (cursor and cursor.valid_for_read) then
		return
	end
	return cursor
end

---@param event EventData.CustomInputEvent
---@return LuaEntityPrototype?
local function get_selected_prototype(event)
	local selected = event.selected_prototype
	if not selected then
		return
	end

	if selected.base_type == "entity" then
		local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
		local selected_entity = player.selected
		if not selected_entity then
			return game.entity_prototypes[selected.name]
		end
		if selected_entity.type == "entity-ghost" and selected_entity.ghost_prototype.type ~= "tile" then
			return selected_entity.ghost_prototype --[[@as LuaEntityPrototype]]
		end
		return selected_entity.prototype

	-- _CodeGreen: I couldn't find anything in game where I could click on an item or recipe that actually had a CustomInputEvent fire
	-- But the code to handle them is here, I guess
	elseif selected.base_type == "item" then
		local item = game.item_prototypes[selected.name]
		local place_result = item.place_result
		if not place_result then
			return
		end
		return place_result
	elseif selected.base_type == "recipe" then
		local recipe = game.recipe_prototypes[selected.name]
		local main_product = recipe.main_product
		local products = main_product and { main_product } or recipe.products
		local item_prototypes = game.item_prototypes
		for _, product in pairs(products) do
			if product.type ~= "item" then
				goto continue
			end
			local item = item_prototypes[product.name]
			local place_result = item.place_result
			if place_result then
				return place_result
			end
			::continue::
		end
	end
end

---@param cursor LuaItemStack
---@param from string
---@param to string?
---@return LocalisedString?
local function add_upgrade_filter(cursor, from, to)
	if not to then
		return "message.bpt-entity-cannot-upgrade"
	end

	local first_index
	for i = 1, cursor.prototype.mapper_count do
		local mapper = cursor.get_mapper(i, "from")
		local name = mapper.name
		if name then
			if mapper.type == "entity" and name == from then
				if cursor.get_mapper(i, "to").name == to then
					return "message.bpt-filter-already-present"
				end
				cursor.set_mapper(i, "to", { type = "entity", name = to })
				return
			end
		else
			first_index = first_index or i
		end
	end

	if not first_index then
		return "message.bpt-filters-full"
	end
	cursor.set_mapper(first_index, "from", { type = "entity", name = from })
	cursor.set_mapper(first_index, "to", { type = "entity", name = to })
end

---@param cursor LuaItemStack
---@param prototype LuaEntityPrototype
---@return LocalisedString?
local function add_filter(cursor, prototype)
	if cursor.is_deconstruction_item then
		local filters = cursor.entity_filters
		if #filters == cursor.entity_filter_count then
			return "message.bpt-filters-full"
		end
		for _, filter in pairs(filters) do
			if filter == prototype.name then
				return "message.bpt-filter-already-present"
			end
		end
		if not cursor.set_entity_filter(#cursor.entity_filters + 1, prototype) then
			return "message.bpt-unable-to-add-filter"
		end
	elseif cursor.is_upgrade_item then
		local next_upgrade = prototype.next_upgrade
		local to = next_upgrade and next_upgrade.name or global.downgrades[prototype.name]
		return add_upgrade_filter(cursor, prototype.name, to)
	end
end

script.on_event("bpt-pipette-add", function(event)
	local cursor = get_cursor_stack(event.player_index)
	if not cursor then
		return
	end
	local prototype = get_selected_prototype(event)
	if not prototype then
		return
	end

	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	local message = add_filter(cursor, prototype)
	if message then
		util.cursor_notification(player, { message }, "utility/cannot_build")
	else
		player.play_sound({ path = "utility/smart_pipette" })
	end
end)

---@param cursor LuaItemStack
---@param prototype LuaEntityPrototype
---@return LocalisedString?
local function remove_filter(cursor, prototype)
	if cursor.is_deconstruction_item then
		local filters = cursor.entity_filters
		for i = 1, cursor.entity_filter_count do
			if filters[i] == prototype.name then
				cursor.set_entity_filter(i, nil)
				return
			end
		end
	elseif cursor.is_upgrade_item then
		for i = 1, cursor.prototype.mapper_count do
			local mapper = cursor.get_mapper(i, "from")
			if mapper.type == "entity" and mapper.name == prototype.name then
				cursor.set_mapper(i, "from", nil)
				cursor.set_mapper(i, "to", nil)
				return
			end
		end
	end

	return "message.bpt-filter-not-present"
end

script.on_event("bpt-pipette-remove", function(event)
	local cursor = get_cursor_stack(event.player_index)
	if not cursor then
		return
	end
	local prototype = get_selected_prototype(event)
	if not prototype then
		return
	end

	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	local message = remove_filter(cursor, prototype)
	if message then
		util.cursor_notification(player, { message }, "utility/cannot_build")
	else
		player.play_sound({ path = "utility/clear_cursor" })
	end
end)

script.on_event("bpt-pipette-downgrade", function(event)
	local cursor = get_cursor_stack(event.player_index)
	if not cursor then
		return
	end
	if not cursor.is_upgrade_item then
		return
	end

	local prototype = get_selected_prototype(event)
	if not prototype then
		return
	end

	local downgrade = global.downgrades[prototype.name]
	local next_upgrade = prototype.next_upgrade
	local to = downgrade or (next_upgrade and next_upgrade.name)

	local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
	local message = add_upgrade_filter(cursor, prototype.name, to)
	if message then
		if message == "message.bpt-entity-cannot-upgrade" then
			message = "message.bpt-entity-cannot-downgrade"
		end
		util.cursor_notification(player, { message }, "utility/cannot_build")
	else
		player.play_sound({ path = "utility/smart_pipette" })
	end
end)

local lib = {}

function lib.cache_downgrades()
	---@type table<string, string>
	local downgrades = {}
	global.downgrades = downgrades

	for name, entity in pairs(game.entity_prototypes) do
		local next_upgrade = entity.next_upgrade
		if next_upgrade then
			downgrades[next_upgrade.name] = name
		end
	end
end

return lib
