local ChunkManager = require(script.Parent.ChunkManager)

ChunkManager.Initialize()

game:GetService("RunService").RenderStepped:Connect(function()
	ChunkManager.Update()
end)
