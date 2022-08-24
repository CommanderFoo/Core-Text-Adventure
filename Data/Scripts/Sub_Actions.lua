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