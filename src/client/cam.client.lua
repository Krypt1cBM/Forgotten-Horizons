local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

local Position = Vector3.new(0, 1000, 0)

local Yaw = 0
local Pitch = 0

local Speed = 200
local SprintSpeed = 1000

RunService.RenderStepped:Connect(function(dt)

	if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local Delta = UIS:GetMouseDelta()

		Yaw -= Delta.X * 0.25
		Pitch -= Delta.Y * 0.25

		Pitch = math.clamp(Pitch, -89, 89)
	end

	local Rotation =
		CFrame.Angles(
			math.rad(Pitch),
			math.rad(Yaw),
			0
		)

	local Move = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then
		Move += Rotation.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.S) then
		Move -= Rotation.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.A) then
		Move -= Rotation.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.D) then
		Move += Rotation.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		Move += Vector3.yAxis
	end

	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
		Move -= Vector3.yAxis
	end

	local CurrentSpeed =
		UIS:IsKeyDown(Enum.KeyCode.LeftShift)
		and SprintSpeed
		or Speed

	if Move.Magnitude > 0 then
		Position += Move.Unit * CurrentSpeed * dt
	end

	Camera.CFrame =
		CFrame.new(Position)
		* Rotation
end)