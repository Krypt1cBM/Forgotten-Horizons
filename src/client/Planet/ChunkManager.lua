local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)

local ChunkManager = {}
local LoadedChunks = {}

function ChunkManager.Initialize()
	local Plan = StreamPlanner.GetPlan("+Y", 5, 5, StreamPlanner.HiddenCorner.SE)

	for _, Data in ipairs(Plan) do
		local ChunkObject = Chunk.new()

		ChunkObject:Generate(Data.Face, Data.ChunkX, Data.ChunkY)

		table.insert(LoadedChunks, ChunkObject)
	end
end

function ChunkManager.Update()
	--local Plan = StreamPlanner.GetPlan()
	--TODO compare loaded chunks
end

return ChunkManager
