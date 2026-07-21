local Constants = require(script.Parent.Parent.Constants)
local PlayerTracker = require(script.Parent.PlayerTracker)

local CameraCollision = {}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function CameraCollision.initialize() end

function CameraCollision.resolve(cameraTarget, desiredPosition)
	raycastParams.FilterDescendantsInstances = { PlayerTracker.character }

	local direction = desiredPosition - cameraTarget
	local distance = direction.Magnitude

	if distance == 0 then
		return desiredPosition
	end

	direction = direction.Unit

	local result = workspace:Spherecast(cameraTarget, Constants.Camera.RADIUS, direction * distance, raycastParams)

	if not result then
		return desiredPosition
	end

	return result.Position - direction * Constants.Camera.COLLISION_PADDING
end

return CameraCollision
