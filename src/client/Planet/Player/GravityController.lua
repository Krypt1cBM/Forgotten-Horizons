local PlayerTracker = require(script.Parent.PlayerTracker)

local Constants = require(script.Parent.Parent.Constants)

local GravityController = {}

local GravityForce

local AlignOrientation
local Attachment

function GravityController.Initialize()
	local RootPart = PlayerTracker.RootPart
	local Humanoid = PlayerTracker.Humanoid

	Humanoid.AutoRotate = false
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	GravityForce = Instance.new("VectorForce")
	GravityForce.Name = "PlanetGravity"

	Attachment = Instance.new("Attachment")
	Attachment.Parent = RootPart
	GravityForce.Attachment0 = Attachment

	GravityForce.RelativeTo = Enum.ActuatorRelativeTo.World
	GravityForce.ApplyAtCenterOfMass = true
	GravityForce.Parent = RootPart

	AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Name = "PlanetAlignment"
	AlignOrientation.Attachment0 = Attachment
	AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	AlignOrientation.RigidityEnabled = true
	AlignOrientation.Responsiveness = 200
	AlignOrientation.Parent = RootPart
end

function GravityController.GetGravityDirection(pos)
	return (Constants.PlanetConstants.CENTER - pos).Unit
end

function GravityController.AlignCharacter()
	local RootPart = PlayerTracker.RootPart
	if not RootPart then
		return
	end

	local Up = PlayerTracker.UpVector
	local Forward = PlayerTracker.ForwardVector

	assert(math.abs(Forward:Dot(Up)) < 0.99, "ForwardVector is parallel to UpVector")

	local Right = Forward:Cross(Up).Unit
	Forward = Up:Cross(Right).Unit

	PlayerTracker.RightVector = Right
	PlayerTracker.ForwardVector = Forward

	AlignOrientation.CFrame = CFrame.fromMatrix(Vector3.zero, Right, Up, -Forward)
end

local function RotateTowards(Current, Target, MaxRadians)
	Current = Current.Unit
	Target = Target.Unit

	local Dot = math.clamp(Current:Dot(Target), -1, 1)
	local Angle = math.acos(Dot)

	if Angle <= MaxRadians then
		return Target
	end

	local Axis = Current:Cross(Target)

	if Axis.Magnitude < 0.001 then
		Axis = PlayerTracker.UpVector
	else
		Axis = Axis.Unit
	end

	local Rotation = CFrame.fromAxisAngle(Axis, MaxRadians)
	return Rotation:VectorToWorldSpace(Current)
end

function GravityController.Update(dt)
	local Position = PlayerTracker.Position
	local Direction = GravityController.GetGravityDirection(Position)

	GravityForce.Force = Direction * Constants.GRAVITY_STRENGTH

	PlayerTracker.GravityDirection = Direction
	PlayerTracker.UpVector = -Direction

	PlayerTracker.ForwardVector = RotateTowards(
		PlayerTracker.ForwardVector,
		PlayerTracker.DesiredForward,
		Constants.MovementConstants.TURN_SPEED * dt
	)

	GravityController.AlignCharacter()
end

return GravityController
