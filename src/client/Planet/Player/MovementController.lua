local userInputService = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local CameraController = require(script.Parent.CameraController)
local Constants = require(script.Parent.Parent.Constants)

local MovementController = {}

local moveInput = Vector2.zero

function MovementController.initialize()
	userInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			moveInput += Vector2.new(0, 1)
		elseif input.KeyCode == Enum.KeyCode.S then
			moveInput += Vector2.new(0, -1)
		elseif input.KeyCode == Enum.KeyCode.A then
			moveInput += Vector2.new(-1, 0)
		elseif input.KeyCode == Enum.KeyCode.D then
			moveInput += Vector2.new(1, 0)
		end
	end)

	userInputService.InputEnded:Connect(function(input, gp)
		if gp then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			moveInput -= Vector2.new(0, 1)
		elseif input.KeyCode == Enum.KeyCode.S then
			moveInput -= Vector2.new(0, -1)
		elseif input.KeyCode == Enum.KeyCode.A then
			moveInput -= Vector2.new(-1, 0)
		elseif input.KeyCode == Enum.KeyCode.D then
			moveInput -= Vector2.new(1, 0)
		end
	end)
end

function MovementController.update()
	if moveInput.Magnitude == 0 then
		PlayerTracker.Humanoid:Move(Vector3.zero)
		return
	end

	local cameraForward = CameraController.GetForward()
	local cameraRight = CameraController.GetRight()

	local up = PlayerTracker.UpVector

	cameraForward = (cameraForward - up * cameraForward:Dot(up)).Unit
	cameraRight = (cameraRight - up * cameraRight:Dot(up)).Unit

	local moveDirection = (cameraForward * moveInput.Y + cameraRight * moveInput.X).Unit

	PlayerTracker.DesiredForward = moveDirection
	PlayerTracker.Humanoid:Move(moveDirection)
end

return MovementController
