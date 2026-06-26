local AssetService = game:GetService("AssetService")

local Chunk = require(script.Parent.Chunk)

local ChunkManager = {}
local LoadedChunks = {}

function ChunkManager.Initialize()
	local Face = "+Y"
	local CenterChunkX = 5
	local CenterChunkY = 5

	for OffsetY = -1, 1 do
		for OffsetX = -1, 1 do
			print("Making Chunk", OffsetX, OffsetY)
			local ChunkObject = Chunk.new()

			ChunkObject:Generate(Face, CenterChunkX + OffsetX, CenterChunkY + OffsetY)

			table.insert(LoadedChunks, ChunkObject)
		end
	end
end

function ChunkManager.Update()
	--TODO player tracker
end

return ChunkManager
