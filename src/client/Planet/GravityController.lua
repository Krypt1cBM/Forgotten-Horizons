local Players = game:GetService("Players")

local Constants = require(script.Parent.Constants)

local GravityController = {}

local Player = Players.LocalPlayer

local Character
local Humanoid
local RootPart
local GravityForce

local AlignOrientation
local Attachment

local GRAVITY_STRENGTH = 500

function GravityController.Initialize()
	Character = Player.Character or Player.CharacterAdded:Wait()
	RootPart = Character:WaitForChild("HumanoidRootPart")

	Humanoid = Character:WaitForChild("Humanoid")
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

function GravityController.GetGravityDirection()
	return (Constants.PLANET_CENTER - RootPart.Position).Unit
end

function GravityController.GetUpDirection()
	if not RootPart then
		return Vector3.zero
	end

	return (RootPart.Position - Constants.PLANET_CENTER).Unit
end

function GravityController.AlignCharacter()
	local Up = GravityController.GetUpDirection()

	local Forward

	if Humanoid.MoveDirection.Magnitude > 0.01 then
		Forward = Humanoid.MoveDirection.Unit
	else
		Forward = RootPart.CFrame.LookVector
	end

	Forward = Forward - Up * Forward:Dot(Up)

	if Forward.Magnitude < 0.001 then
		Forward = RootPart.CFrame.RightVector:Cross(Up)
	end

	Forward = Forward.Unit

	AlignOrientation.CFrame = CFrame.lookAt(Vector3.zero, Forward, Up)
end

function GravityController.Update()
	if not RootPart then
		return
	end
	print(Humanoid:GetState())

	local Direction = GravityController.GetGravityDirection()

	GravityForce.Force = Direction * GRAVITY_STRENGTH

	GravityController.AlignCharacter()
end

return GravityController
