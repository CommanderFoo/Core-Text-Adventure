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