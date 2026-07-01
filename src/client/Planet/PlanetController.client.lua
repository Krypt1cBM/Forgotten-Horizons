local rs = game:GetService("RunService")

--Player
local PlayerTracker = require(script.Parent.Player.PlayerTracker)
local GravityController = require(script.Parent.Player.GravityController)
local CameraController = require(script.Parent.Player.CameraController)
local MovementController = require(script.Parent.Player.MovementController)
local CameraCollision = require(script.Parent.Player.CameraCollision)

--Generation
local ChunkManager = require(script.Parent.Generation.ChunkManager)

--Player
PlayerTracker.initialize()
GravityController.initialize()
CameraController.initialize()
MovementController.initialize()
CameraCollision.initialize()

--Generation
ChunkManager.initialize()

rs.RenderStepped:Connect(function(dt)
	CameraController.update(dt)
end)

rs.Heartbeat:Connect(function(dt)
	PlayerTracker.update(dt)

	GravityController.update(dt)
	MovementController.update(dt)
	ChunkManager.update(dt)
end)
