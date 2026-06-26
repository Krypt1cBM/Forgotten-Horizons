local rs = game:GetService("RunService")

local ChunkManager = require(script.Parent.ChunkManager)
local GravityController = require(script.Parent.GravityController)

ChunkManager.Initialize()
GravityController.Initialize()

rs.RenderStepped:Connect(function()
	ChunkManager.Update()
end)
rs.Heartbeat:Connect(function()
	GravityController.Update()
end)
