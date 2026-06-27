local Players = game:GetService("Players")

local PlayerTracker = {}

local Player = Players.LocalPlayer
PlayerTracker.Character = nil
PlayerTracker.Humanoid = nil
PlayerTracker.RootPart = nil

PlayerTracker.UpVector = Vector3.yAxis
PlayerTracker.GravityDirection = -Vector3.yAxis

PlayerTracker.CharacterForward = Vector3.zAxis --want to face
PlayerTracker.DesiredForward = Vector3.zAxis --is facing

PlayerTracker.Position = Vector3.zero

local function SetCharacter(Character)
	PlayerTracker.Character = Character
	PlayerTracker.Humanoid = Character:WaitForChild("Humanoid")
	PlayerTracker.RootPart = Character:WaitForChild("HumanoidRootPart")
end

function PlayerTracker.Initialize()
	PlayerTracker.Camera = workspace.CurrentCamera

	local Character = Player.Character or Player.CharacterAdded:Wait()
	SetCharacter(Character)

	Player.CharacterAdded:Connect(SetCharacter)

	local PlayerScript = Player:WaitForChild("PlayerScripts")
	local PlayerModule = require(PlayerScript:WaitForChild("PlayerModule"))

	local Controls = PlayerModule:GetControls()
	Controls:Disable()
end

function PlayerTracker.Update()
	if PlayerTracker.RootPart then
		PlayerTracker.Position = PlayerTracker.RootPart.Position
	end
end

return PlayerTracker
