local Players = game:GetService("Players")

local PlayerTracker = {}

local player = Players.LocalPlayer

PlayerTracker.character = nil
PlayerTracker.humanoid = nil
PlayerTracker.rootPart = nil

PlayerTracker.gravityDirection = -Vector3.yAxis

PlayerTracker.upVector = Vector3.yAxis
PlayerTracker.forwardVector = Vector3.zAxis
PlayerTracker.desiredForward = Vector3.zAxis
PlayerTracker.rightVector = Vector3.xAxis

PlayerTracker.position = Vector3.zero
PlayerTracker.isGrounded = false
PlayerTracker.groundResult = nil

local function setCharacter(character)
	PlayerTracker.character = character
	PlayerTracker.humanoid = character:WaitForChild("Humanoid")
	PlayerTracker.rootPart = character:WaitForChild("HumanoidRootPart")
end

function PlayerTracker.initialize()
	PlayerTracker.camera = workspace.CurrentCamera

	local character = player.Character or player.CharacterAdded:Wait()
	setCharacter(character)

	player.CharacterAdded:Connect(setCharacter)

	local playerScript = player:WaitForChild("PlayerScripts")
	local playerModule = require(playerScript:WaitForChild("PlayerModule"))

	local controls = playerModule:GetControls()
	controls:Disable()
end

function PlayerTracker.update()
	if PlayerTracker.rootPart then
		PlayerTracker.position = PlayerTracker.rootPart.Position
	end
end

return PlayerTracker
