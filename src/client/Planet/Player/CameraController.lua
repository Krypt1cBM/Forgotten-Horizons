local UIS = game:GetService("UserInputService")

local PlayerTracker = require(script.Parent.PlayerTracker)
local Constants = require(script.Parent.Parent.Constants)
local MathUtils = require(game.ReplicatedStorage.Scripts.MathUtils)
local CameraCollision = require(script.Parent.CameraCollision)

local CameraController = {}

local camera
local cameraForwardReference

local cameraYaw = 0
local cameraPitch = 0

local orbitHeld = false
local orbitLocked = false

local distance = 12
local height = 1

local mouseDelta = Vector2.zero
local scrollDelta = 0

function CameraController.initialize()
	camera = PlayerTracker.camera
	camera.CameraType = Enum.CameraType.Scriptable

	local forward = PlayerTracker.forwardVector.Unit

	cameraForwardReference = forward

	UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			orbitHeld = true
		end
	end)

	UIS.InputEnded:Connect(function(input, gp)
		if gp then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			orbitHeld = false
		end
	end)

	UIS.InputChanged:Connect(function(input, gp)
		if gp then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mouseDelta = input.Delta
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			scrollDelta = input.Position.Z
		end
	end)
end

local function getCameraBasis(up)
	local forward = cameraForwardReference

	forward = forward - up * forward:Dot(up)

	if forward.Magnitude < 0.001 then
		forward = PlayerTracker.forwardVector
		forward = forward - up * forward:Dot(up)
	end
	forward = forward.Unit

	cameraForwardReference = forward

	local right = forward:Cross(up).Unit
	return right, forward
end

local function calculateOffset(up)
	local right, forward = getCameraBasis(up)

	local yawRotation = CFrame.fromAxisAngle(up, cameraYaw)

	forward = yawRotation:VectorToWorldSpace(forward)
	right = yawRotation:VectorToWorldSpace(right)

	local pitchRotation = CFrame.fromAxisAngle(right, cameraPitch)

	forward = pitchRotation:VectorToWorldSpace(forward)

	return -forward * distance
end

function CameraController.update()
	local up = PlayerTracker.upVector
	local cameraTarget = PlayerTracker.position + up * height

	if orbitHeld or orbitLocked then
		cameraYaw -= mouseDelta.X * Constants.Camera.SENSITIVITY
		cameraPitch -= mouseDelta.Y * Constants.Camera.SENSITIVITY

		cameraPitch = math.clamp(cameraPitch, Constants.Camera.MIN_PITCH, Constants.Camera.MAX_PITCH)

		mouseDelta = Vector2.zero
	end

	if scrollDelta ~= 0 then
		local distanceFactor =
			MathUtils.inverseLerp(distance, Constants.Camera.MIN_DISTANCE, Constants.Camera.MAX_DISTANCE)

		local zoomFactor = MathUtils.smoothStep(distanceFactor)

		local finalZoomSpeed =
			MathUtils.lerp(Constants.Camera.MIN_ZOOM_SPEED, Constants.Camera.MAX_ZOOM_SPEED, zoomFactor)

		distance -= scrollDelta * finalZoomSpeed
	end

	distance = math.clamp(distance, Constants.Camera.MIN_DISTANCE, Constants.Camera.MAX_DISTANCE)
	scrollDelta = 0

	local desiredPosition = cameraTarget + calculateOffset(up)

	local safePosition = CameraCollision.resolve(cameraTarget, desiredPosition)

	camera.CFrame = CFrame.lookAt(safePosition, cameraTarget, up)
end

function CameraController.getForward()
	return camera.CFrame.LookVector
end

function CameraController.getRight()
	return camera.CFrame.RightVector
end

return CameraController
