local AssetService = game:GetService("AssetService")

local ChunkGenerator = require(script.Parent.ChunkGenerator)

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new()
	local self = setmetatable({}, Chunk)

	self.Face = nil
	self.ChunkX = nil
	self.ChunkY = nil

	self.EditableMesh = AssetService:CreateEditableMesh()
	self.MeshPart = nil

	return self
end

function Chunk:Generate(Face, ChunkX, ChunkY)
	self.Face = Face
	self.ChunkX = ChunkX
	self.ChunkY = ChunkY

	ChunkGenerator.Generate(self.EditableMesh, Face, ChunkX, ChunkY)

	if self.MeshPart then
		self.MeshPart:Destroy()
	end

	local MeshPart = AssetService:CreateMeshPartAsync(Content.fromObject(self.EditableMesh), {
		CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
	})

	MeshPart.Anchored = true
	MeshPart.Parent = workspace

	self.MeshPart = MeshPart
end

function Chunk:Recycle(Face, ChunkX, ChunkY)
	self:Generate(Face, ChunkX, ChunkY)
end

return Chunk
