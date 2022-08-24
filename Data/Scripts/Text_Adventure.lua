local ACTIONS = require(script:GetCustomProperty("Actions"))
local SUB_ACTIONS = require(script:GetCustomProperty("Sub_Actions"))

---@class Text_Adventure
local Text_Adventure = {

	current_area = 1,
	AREAS = require(script:GetCustomProperty("Areas")),
	visited = { false, false, false, false}

}

function Text_Adventure.init(action_box, feed_box)
	Text_Adventure.action_box = action_box
	Text_Adventure.feed_box = feed_box
end

function Text_Adventure.parse(player, text)
	local params = { CoreString.Split(text, { delimiters = " ", removeEmptyResults = true })}

	if(params[1] ~= nil and string.len(params[1]) > 0 and ACTIONS[string.lower(params[1])] ~= nil) then
		ACTIONS[string.lower(params[1])](player, params)
	end

	Text_Adventure.action_box.text = ""
end

function Text_Adventure.travel_to(area_index, area_row, action)
	local has_visited = Text_Adventure.visited[area_index]
	local first_text = nil

	if(not has_visited) then
		first_text = area_row.FirstText
	end

	Text_Adventure.current_area = area_index
	Text_Adventure.visited[area_index] = true
	Text_Adventure.show_area_text(area_row.Text, action, first_text)
end

function Text_Adventure.get_current_area()
	return Text_Adventure.AREAS[Text_Adventure.current_area]
end

function Text_Adventure.show_warning(str)
	Text_Adventure.feed_box.text = Text_Adventure.feed_box.text .. "\n\n> " .. str
end

function Text_Adventure.show_area_text(text, action, first_text)
	if(first_text ~= nil and string.len(first_text) > 0) then
		first_text = "   " .. first_text
		text = text .. "\n\n"
	end

	if(action ~= nil and string.len(action) > 0) then
		action = "> " .. action .. "\n\n"
	end

	Text_Adventure.feed_box.text = Text_Adventure.feed_box.text .. "\n\n" .. (action or "") .. "   " .. text .. (first_text or "")
end

function Text_Adventure.start()
	Text_Adventure.current_area = 1
	Text_Adventure.visited[1] = true
	Text_Adventure.show_area_text("", nil, Text_Adventure.AREAS[1].FirstText)
end

function Text_Adventure.get_sub_action(sub_action)
	return SUB_ACTIONS[sub_action]
end

ACTIONS.set_text_adventure(Text_Adventure)
SUB_ACTIONS.set_text_adventure(Text_Adventure)

return Text_Adventure