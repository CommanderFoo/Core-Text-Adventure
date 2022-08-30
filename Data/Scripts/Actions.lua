---@type Text_Adventure
local Text_Adventure = nil

---@class Actions
local Actions = {}

function Actions.set_text_adventure(ta)
	Text_Adventure = ta
end

function Actions.find(text, list)
	if(text ~= nil and string.len(text) > 0) then
		for index, word in ipairs(list) do
			if(string.lower(text) == word) then
				return true
			end
		end
	end

	return false
end

function Actions.get_row_by_name(name)
	for index, row in ipairs(Text_Adventure.AREAS) do
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
	local area = Text_Adventure.get_current_area()

	if(Actions.find(params[2], { "north", "east", "south", "west" })) then
		local dir = string.sub(params[2], 1, 1):upper() .. string.sub(params[2], 2):lower()

		if(area[dir]) then
			local area_index, area_row = Actions.get_row_by_name(dir)
			
			Text_Adventure.travel_to(area_index, area_row, params[1] .. " " .. params[2])

			return
		end
	end

	Text_Adventure.show_warning(string.format("\"%s\" is not valid. Options are: %s.", params[2], Actions.get_valid_directions(area)))
end

function Actions.look(player, params, feed_text)
	local area = Text_Adventure.get_current_area()
	local items = area.Items
	local items_txt = "There are no items to look for."

	if(items ~= nil and #items > 0) then
		items_txt = "The following items can be seen: "

		for index, item in ipairs(items) do
			items_txt = items_txt .. item.Name .. ", "
		end

		items_txt = string.sub(items_txt, 1, -3)
	end

	Text_Adventure.show_area_text(items_txt, "Look")
end

function Actions.inspect(player, params, feed_text)
	local area = Text_Adventure.get_current_area()
	local items = area.Items
	local the_item = string.lower(params[2] or "")

	if(the_item ~= "" and items ~= nil and #items > 0) then
		local name = nil
		local desc = nil
		local sub_action = ""

		for index, item in ipairs(items) do
			if(the_item == string.lower(item.Name)) then
				name = item.Name
				desc = item.Description
				sub_action = item.SubAction

				break
			end
		end

		if(name and desc) then
			Text_Adventure.show_area_text(desc, "Inspect " .. name)
		end

		if(string.len(sub_action) > 0) then
			Text_Adventure.get_sub_action(sub_action)(player)
			return
		end

		return
	elseif(the_item == "") then
		Text_Adventure.show_warning("Can't inspect nothing.")

		return
	end

	Text_Adventure.show_warning(string.format("\"%s\" is not valid.", params[2]))
end

return Actions
