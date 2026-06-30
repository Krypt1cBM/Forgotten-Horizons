local UIS = game:GetService("UserInputService")
local PlayerTracker = require(script.Parent.PlayerTracker)
local Constants = require(script.Parent.Parent.Constants)
local MathUtils = require(game.ReplicatedStorage.Scripts.MathUtils)

local CameraController = {}

local Camera

local OrbitHeld = false
local OrbitLocked = false

local CameraYaw = 0
local CameraPitch = 0

local Distance = 12
local Height = 1

local MouseDelta = Vector2.zero
local ScrollDelta = 0

function CameraController.Initialize()
	Camera = PlayerTracker.Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			OrbitHeld = true
		end
	end)

	UIS.InputEnded:Connect(function(input, gp)
		if gp then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			OrbitHeld = false
		end
	end)

	UIS.InputChanged:Connect(function(input, gp)
		if gp then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			MouseDelta = input.Delta
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			ScrollDelta = input.Position.Z
		end
	end)
end

local function CalculateOffset(Up)
	local CameraOffset = Vector3.new(0, Height, -Distance)

	local YawOffset = CFrame.fromAxisAngle(Up, CameraYaw)
	local RotatedOffset = YawOffset:VectorToWorldSpace(CameraOffset)

	local BoomDirection = RotatedOffset.Unit
	local CameraRight = BoomDirection:Cross(Up)

	local PitchRotation = CFrame.fromAxisAngle(CameraRight, CameraPitch)
	return PitchRotation:VectorToWorldSpace(RotatedOffset)
end

function CameraController.Update()
	if OrbitHeld or OrbitLocked then
		CameraYaw -= MouseDelta.X * Constants.CameraConstants.SENSITIVITY
		CameraPitch += MouseDelta.Y * Constants.CameraConstants.SENSITIVITY
		CameraPitch = math.clamp(CameraPitch, Constants.CameraConstants.MIN_PITCH, Constants.CameraConstants.MAX_PITCH)
		MouseDelta = Vector2.zero
	end

	local Up = PlayerTracker.UpVector
	local CameraTarget = PlayerTracker.Position + Up * Height

	if ScrollDelta ~= 0 then
		local DistanceFactor = MathUtils.InverseLerp(
			Distance,
			Constants.CameraConstants.MIN_DISTANCE,
			Constants.CameraConstants.MAX_DISTANCE
		)
		local ZoomFactor = MathUtils.SmoothStep(DistanceFactor)
		local FinalZoomSpeed = MathUtils.Lerp(
			Constants.CameraConstants.MIN_ZOOM_SPEED,
			Constants.CameraConstants.MAX_ZOOM_SPEED,
			ZoomFactor
		)

		Distance -= ScrollDelta * FinalZoomSpeed
	end

	Distance = math.clamp(Distance, Constants.CameraConstants.MIN_DISTANCE, Constants.CameraConstants.MAX_DISTANCE)
	ScrollDelta = 0

	local CameraPosition = CameraTarget + CalculateOffset(Up)

	Camera.CFrame = CFrame.lookAt(CameraPosition, CameraTarget, Up)
end

function CameraController.GetForward()
	return Camera.CFrame.LookVector
end
function CameraController.GetRight()
	return Camera.CFrame.RightVector
end

return CameraController
