local PlayerTracker = require(script.Parent.PlayerTracker)

local Constants = require(script.Parent.Parent.Constants)

local GravityController = {}

local gravityForce

local alignOrientation
local attachment

function GravityController.initialize()
	local rootPart = PlayerTracker.RootPart
	local humanoid = PlayerTracker.Humanoid

	humanoid.AutoRotate = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	gravityForce = Instance.new("VectorForce")
	gravityForce.Name = "PlanetGravity"

	attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	gravityForce.Attachment0 = attachment

	gravityForce.RelativeTo = Enum.ActuatorRelativeTo.World
	gravityForce.ApplyAtCenterOfMass = true
	gravityForce.Parent = rootPart

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "PlanetAlignment"
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.RigidityEnabled = true
	alignOrientation.Responsiveness = 200
	alignOrientation.Parent = rootPart
end

function GravityController.getGravityDirection(position)
	return (Constants.Planet.CENTER - position).Unit
end

function GravityController.alignCharacter()
	local rootPart = PlayerTracker.RootPart
	if not rootPart then
		return
	end

	local up = PlayerTracker.UpVector
	local forward = PlayerTracker.ForwardVector

	assert(math.abs(forward:Dot(up)) < 0.99, "ForwardVector is parallel to UpVector")

	local right = forward:Cross(up).Unit
	forward = up:Cross(right).Unit

	PlayerTracker.RightVector = right
	PlayerTracker.ForwardVector = forward

	alignOrientation.CFrame = CFrame.fromMatrix(Vector3.zero, right, up, -forward)
end

local function rotateTowards(current, target, maxRadians)
	current = current.Unit
	target = target.Unit

	local dot = math.clamp(current:Dot(target), -1, 1)
	local angle = math.acos(dot)

	if angle <= maxRadians then
		return target
	end

	local axis = current:Cross(target)

	if axis.Magnitude < 0.001 then
		axis = PlayerTracker.UpVector
	else
		axis = axis.Unit
	end

	local rotation = CFrame.fromAxisAngle(axis, maxRadians)
	return rotation:VectorToWorldSpace(current)
end

function GravityController.update(dt)
	local position = PlayerTracker.Position
	local direction = GravityController.getGravityDirection(position)

	gravityForce.Force = direction * Constants.GRAVITY_STRENGTH

	PlayerTracker.GravityDirection = direction
	PlayerTracker.UpVector = -direction

	PlayerTracker.ForwardVector =
		rotateTowards(PlayerTracker.ForwardVector, PlayerTracker.DesiredForward, Constants.Movement.TURN_SPEED * dt)

	GravityController.alignCharacter()
end

return GravityController
