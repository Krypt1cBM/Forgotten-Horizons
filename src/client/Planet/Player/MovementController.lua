local UIS = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local Constants = require(script.Parent.Parent.Constants)

local MovementController = {}

local MoveInput = Vector2.zero

function MovementController.Initialize()
	UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			MoveInput += Vector2.new(0, 1)
		elseif input.KeyCode == Enum.KeyCode.S then
			MoveInput += Vector2.new(0, -1)
		elseif input.KeyCode == Enum.KeyCode.A then
			MoveInput += Vector2.new(-1, 0)
		elseif input.KeyCode == Enum.KeyCode.D then
			MoveInput += Vector2.new(1, 0)
		end
	end)

	UIS.InputEnded:Connect(function(input, gp)
		if gp then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			MoveInput -= Vector2.new(0, 1)
		elseif input.KeyCode == Enum.KeyCode.S then
			MoveInput -= Vector2.new(0, -1)
		elseif input.KeyCode == Enum.KeyCode.A then
			MoveInput -= Vector2.new(-1, 0)
		elseif input.KeyCode == Enum.KeyCode.D then
			MoveInput -= Vector2.new(1, 0)
		end
	end)
end

function MovementController.Update(dt) end

return MovementController
