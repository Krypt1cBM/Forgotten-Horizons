local UIS = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local CameraController = require(script.Parent.CameraController)
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

function MovementController.Update()
	if MoveInput.Magnitude == 0 then
		PlayerTracker.Humanoid:Move(Vector3.zero)
		return
	end

	local CameraForward = CameraController.GetForward()
	local CameraRight = CameraController.GetRight()

	local Up = PlayerTracker.UpVector

	CameraForward = (CameraForward - Up * CameraForward:Dot(Up)).Unit
	CameraRight = (CameraRight - Up * CameraRight:Dot(Up)).Unit

	local MoveDirection = (CameraForward * MoveInput.Y + CameraRight * MoveInput.X).Unit

	PlayerTracker.DesiredForward = MoveDirection
	PlayerTracker.Humanoid:Move(MoveDirection)
end

return MovementController
