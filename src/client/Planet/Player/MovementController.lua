local userInputService = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local CameraController = require(script.Parent.CameraController)
local Constants = require(script.Parent.Parent.Constants)
local MathUtils = require(game.ReplicatedStorage.Scripts.MathUtils)

local MovementController = {}

local moveInput = Vector2.zero

local sprinting = false
local jumpStarted = false

local movementVectorForce
local movementAttachment

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function MovementController.initialize()
	raycastParams.FilterDescendantsInstances = { PlayerTracker.character }

	movementAttachment = Instance.new("Attachment")
	movementAttachment.Name = "MovementAttachment"
	movementAttachment.Parent = PlayerTracker.rootPart

	movementVectorForce = Instance.new("VectorForce")
	movementVectorForce.Name = "MovementForce"
	movementVectorForce.Attachment0 = movementAttachment
	movementVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	movementVectorForce.ApplyAtCenterOfMass = true
	movementVectorForce.Parent = PlayerTracker.rootPart

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

function MovementController.update(dt)
	updateGrounded()

	if PlayerTracker.isGrounded and jumpStarted then
		jump()
	end

	local targetSpeed = Constants.Movement.MAX_SPEED
	if sprinting then
		targetSpeed = Constants.Movement.SPRINT_SPEED
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

	local desiredVelocity = moveDirection * targetSpeed
	local rootPart = PlayerTracker.rootPart
	local currentVelocity = rootPart.AssemblyLinearVelocity

	local horizontalVelocity = MathUtils.projectOntoPlane(currentVelocity, PlayerTracker.upVector)

	local velocityError = desiredVelocity - horizontalVelocity

	local acceleration = Constants.Movement.AIR_ACCELERATION
	if PlayerTracker.isGrounded then
		acceleration = Constants.Movement.GROUND_ACCELERATION
	end

	local maxVelocityChange = acceleration * dt
	local velocityChange

	if velocityError.Magnitude <= maxVelocityChange then
		velocityChange = velocityError
	else
		velocityChange = velocityError.Unit * maxVelocityChange
	end

	local requiredAcceleration = velocityChange / dt

	local movementForce = requiredAcceleration * PlayerTracker.rootPart.AssemblyMass
	movementVectorForce.Force = movementForce
	print(desiredVelocity, horizontalVelocity)

	jumpStarted = false
end

return MovementController
