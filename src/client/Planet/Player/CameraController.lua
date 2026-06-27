local PlayerTracker = require(script.Parent.PlayerTracker)

local CameraController = {}

local Camera

local Distance = 12
local Height = 3

local Sensitivity = 0.003

local MinPitch = math.rad(-80)
local MaxPitch = math.rad(80)

function CameraController.Initialize()
	Camera = PlayerTracker.Camera
	Camera.CameraType = Enum.CameraType.Scriptable
end

function CameraController.Update(dt)
	local Up = PlayerTracker.UpVector
	local Forward = PlayerTracker.ForwardVector

	local CameraPosition = PlayerTracker.RootPart.Position + Up * Height - Forward * Distance

	Camera.CFrame = CFrame.lookAt(CameraPosition, PlayerTracker.RootPart.Position, Up)
end

return CameraController
