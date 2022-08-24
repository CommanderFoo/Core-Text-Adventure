# Text Entry Box

The Text Entry Box object allows you to provide a way for your players to enter text. This could be used to name a pet, enter commands instead of using the chat, or even an old style text adventure game. You can capture the changed and submitted text and do with it what you need from there.

We have a couple of tutorials that go over the text entry box.

There is a Pet Naming tutorial by Aaron that will show you how to create a UI prompt allowing the player to rename a pet spider. The player will also greet the pet using its given name.

There is one by me that teaches how to validate the text that players can enter into a Text Entry Box to make sure only certain values or lengths can be entered. Validation can be done for numeric values and text. For example, a player that can enter a name for a pet they own might need restrictions on the length of the name, and what characters or words are used.

## Text Adventure Example

1. Create client context
2. Create UI Container
3. Create background image full black color
4. Create panel inherit width and height, add self size (2164, 280). Opacity mask gradient circular (.578).
5. Create lines image (tiled wicker), green color inherit width and height.

6. Create header image green color, inherit width, 60 height, top center top center.
7. Create text box for game name. Roboto Slab font. 24 font size, 20 x offset, 200 width, 60 height, middle left middle left.

8. Create action panel, inherit width, 60 height, bottom center bottom center.
9. Create background image, green inherit width and height.
10. Create text entry box. Width -30, height 50. Inherit width. Roboto Slab 25 font size. Green color, selection darker green.

11. Create Feed panel. X offset 20, y offset 70, width -60, height -150, inherit width and height, add self to size. Top left top left.
12. Create feed box, gree, roboto slab 28, inherit width and height. Top left top left

13. Create Text_Adventure_Clint script. (add properties, Action Bar and Feedbox).

14. Create Areas data table (Name, Text, FirstText, Items, North, South, East West)

## Thinking

colossal cave adventure

Areas - South, east, west, north

	South
	You have washed ashore on a deserted island. After the ship was sunk by the mighty Kraken, you managed to escape by the grace of Captain Black Beard. Looking around you see parts of the ship washed ashore alongside you. You seem to be the only survivor. Maybe you should look around and see what resources there are to be found.

	East
	You have entered an area that is covered in rocks.

	West
	The area is overgrown apart from a small patch of mud that looks to have been disturbed.

	North
	Nothing here. Go back.

Actions like look, go, inspect.
Sub actions like the player being killed.
South items (Name, Description, SubAction)

## Text_Adventure

```lua
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
```

## Text_Adventure_Client

Explain bug with wrapping.

```
---@type Text_Adventure
local Text_Adventure = require(script:GetCustomProperty("Text_Adventure"))

---@type UITextEntry
local ACTION_BOX = script:GetCustomProperty("ActionBox"):WaitForObject()

---@type UIText
local FEED_BOX = script:GetCustomProperty("FeedBox"):WaitForObject()

UI.SetCanCursorInteractWithUI(true)
UI.SetCursorVisible(true)

local size = FEED_BOX:ComputeApproximateSize()

while(size == nil) do
	size = FEED_BOX:ComputeApproximateSize()
	Task.Wait()
end

Task.Wait(.2)
FEED_BOX.shouldWrapText = true

ACTION_BOX.textCommittedEvent:Connect(Text_Adventure.parse)

Text_Adventure.init(ACTION_BOX, FEED_BOX)
Text_Adventure.start()
```

## Actions Script

```lua
---@type Text_Adventure
local Text_Adventure = nil

---@class Actions
local Actions = {}

function Actions.set_text_adventure(ta)
	Text_Adventure = ta
end

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
```

##

## Sub Actions

```lua
--@type Text_Adventure
local Text_Adventure = nil

---class Sub_Actions
local Sub_Actions = {}

function Sub_Actions.set_text_adventure(ta)
	Text_Adventure = ta
end

function Sub_Actions.kill_player()
	Text_Adventure.show_area_text("You fell down the hole and died a painful death. Splat.")
end

return Sub_Actions
```