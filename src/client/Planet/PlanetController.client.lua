local rs = game:GetService("RunService")

local PlayerTracker = require(script.Parent.Player.PlayerTracker)
local GravityController = require(script.Parent.Player.GravityController)
local CameraController = require(script.Parent.Player.CameraController)
local MovementController = require(script.Parent.Player.MovementController)
local ChunkManager = require(script.Parent.Generation.ChunkManager)

PlayerTracker.Initialize()
GravityController.Initialize()
CameraController.Initialize()
MovementController.Initialize()

ChunkManager.Initialize()

rs.RenderStepped:Connect(function(dt)
	CameraController.Update(dt)
end)

rs.Heartbeat:Connect(function(dt)
	PlayerTracker.Update(dt)

	GravityController.Update(dt)
	MovementController.Update(dt)
	ChunkManager.Update(dt)
end)
