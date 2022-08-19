---@class Actions
local Actions = {

	---@type Text_Adventure
	Text_Adventure = nil

}

function Actions.find(text, list)
	if(string.len(text) > 0) then
		for index, word in ipairs(list) do
			if(string.lower(text) == word) then
				return true
			end
		end
	end

	return false
end

function Actions.get_row_by_name(name)
	for index, row in ipairs(Actions.Text_Adventure.AREAS) do
		if(row.Name == name) then
			return index, row
		end
	end
end

function Actions.get_valid_directions(area)
	local opts = ""

	if(area.North) then
		opts = opts .. "North,"
	end

	if(area.East) then
		opts = opts .. " East,"
	end

	if(area.South) then
		opts = opts .. " South,"
	end

	if(area.West) then
		opts = opts .. " West,"
	end

	opts = string.sub(opts, 1, -2)

	return opts
end

function Actions.go(player, params, feed_text)
	local area = Actions.Text_Adventure.get_current_area()

	if(Actions.find(params[2], { "north", "east", "south", "west" })) then
		local dir = string.sub(params[2], 1, 1):upper() .. string.sub(params[2], 2):lower()

		if(area[dir]) then
			local area_index, area_row = Actions.get_row_by_name(dir)
			
			Actions.Text_Adventure.travel_to(area_index, area_row, params[1] .. " " .. params[2])

			return
		end
	end

	Actions.Text_Adventure.show_warning(string.format("\"%s\" is not valid. Options are: %s.", params[2], Actions.get_valid_directions(area)))
end

return Actions