local userInputService = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local CameraController = require(script.Parent.CameraController)
local Constants = require(script.Parent.Parent.Constants)

local MovementController = {}

local moveInput = Vector2.zero

local sprinting = false
local jumpHeld = false
local jumpStarted = false
local wasGrounded = false

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function MovementController.initialize()
	raycastParams.FilterDescendantsInstances = { PlayerTracker.character }

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
		elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprinting = true
		elseif input.KeyCode == Enum.KeyCode.Space then
			jumpHeld = true
			jumpStarted = true
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
		elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprinting = false
		elseif input.KeyCode == Enum.KeyCode.Space then
			jumpHeld = false
		end
	end)
end

local function updateGrounded()
	local origin = PlayerTracker.rootPart.Position - PlayerTracker.gravityDirection * 0.5
	local direction = PlayerTracker.gravityDirection * Constants.Movement.GROUND_CHECK_DISTANCE

	local result = workspace:Raycast(origin, direction, raycastParams)
	PlayerTracker.isGrounded = result ~= nil
	PlayerTracker.groundResult = result
end

local function jump()
	local rootPart = PlayerTracker.rootPart

	rootPart:ApplyImpulse(PlayerTracker.upVector * Constants.Movement.JUMP_FORCE * rootPart.AssemblyMass)
end

function MovementController.update()
	updateGrounded()

	local justLanded = not wasGrounded and PlayerTracker.isGrounded

	if jumpStarted then
		print(PlayerTracker.isGrounded)
	end
	if PlayerTracker.isGrounded and (jumpStarted or (justLanded and jumpHeld)) then
		jump()
	end

	local moveSpeed = Constants.Movement.MOVE_SPEED
	if sprinting then
		moveSpeed = Constants.Movement.SPRINT_SPEED
	end

	local moveDirection = Vector3.zero

	if moveInput.Magnitude > 0 then
		local cameraForward = CameraController.getForward()
		local cameraRight = CameraController.getRight()

		local up = PlayerTracker.upVector

		cameraForward = (cameraForward - up * cameraForward:Dot(up)).Unit
		cameraRight = (cameraRight - up * cameraRight:Dot(up)).Unit

		moveDirection = (cameraForward * moveInput.Y + cameraRight * moveInput.X).Unit
		PlayerTracker.desiredForward = moveDirection
	end

	PlayerTracker.humanoid.WalkSpeed = moveSpeed
	PlayerTracker.humanoid:Move(moveDirection)

	jumpStarted = false
	wasGrounded = PlayerTracker.isGrounded
end

return MovementController
