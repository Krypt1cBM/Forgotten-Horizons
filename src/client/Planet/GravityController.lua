local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Constants = require(script.Parent.Constants)

local GravityController = {}

local Player = Players.LocalPlayer

local Character
local RootPart
local GravityForce

local GRAVITY_STRENGTH = 0.5

function GravityController.Initialize()
	Character = Player.Character or Player.CharacterAdded:Wait()
	RootPart = Character:WaitForChild("HumanoidRootPart")

	local Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.AutoRotate = false

	GravityForce = Instance.new("VectorForce")
	GravityForce.Name = "PlanetGravity"

	local Attachment0 = Instance.new("Attachment")
	Attachment0.Parent = RootPart
	GravityForce.Attachment0 = Instance.new("Attachment")

	GravityForce.RelativeTo = Enum.ActuatorRelativeTo.World
	GravityForce.ApplyAtCenterOfMass = true
	GravityForce.Parent = RootPart
end

function GravityController.GetGravityDirection()
	return (Constants.PLANET_CENTER - RootPart.Position).Unit
end

function GravityController.Update()
	if not RootPart then
		return
	end

	local Direction = GravityController.GetGravityDirection()

	RootPart.AssemblyLinearVelocity += Direction * GRAVITY_STRENGTH
end

return GravityController
