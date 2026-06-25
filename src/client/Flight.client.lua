local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local plane = workspace:WaitForChild("Spaceship Jet")
local remote = plane:WaitForChild("Body"):WaitForChild("PrimaryPart"):WaitForChild("ControlEvent")

local controls = {
	Pitch = 0,
	Yaw = 0,
	Roll = 0,
	Throttle = 0
}

local function seatedInPlane()
	local character = player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end

	local seat = humanoid.SeatPart
	if not seat then
		return false
	end

	return seat == plane.Body.VehicleSeat
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.W then
		controls.Pitch = -1
	elseif input.KeyCode == Enum.KeyCode.S then
		controls.Pitch = 1

	elseif input.KeyCode == Enum.KeyCode.A then
		controls.Roll = -1
	elseif input.KeyCode == Enum.KeyCode.D then
		controls.Roll = 1

	elseif input.KeyCode == Enum.KeyCode.Q then
		controls.Yaw = 1
	elseif input.KeyCode == Enum.KeyCode.E then
		controls.Yaw = -1

	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		controls.Throttle = 1
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		controls.Throttle = -1
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
		controls.Pitch = 0

	elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
		controls.Roll = 0

	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.E then
		controls.Yaw = 0

	elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.LeftShift then
		controls.Throttle = 0
	end
end)

RunService.RenderStepped:Connect(function()
	if seatedInPlane() then
		remote:FireServer(controls)
	end
end)