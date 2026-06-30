local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)

local ChunkManager = {}

local loadedChunks = {}

function ChunkManager.initialize()
	local plan = StreamPlanner.getPlan("+Y", 5, 5, StreamPlanner.HiddenCorner.SE)

	for _, data in ipairs(plan) do
		local chunkObject = Chunk.new()

		chunkObject:generate(data.face, data.chunkX, data.chunkY)

		table.insert(loadedChunks, chunkObject)
	end
end

function ChunkManager.update()
	--local plan = StreamPlanner.getPlan()
	--TODO compare loaded chunks
end

return ChunkManager
