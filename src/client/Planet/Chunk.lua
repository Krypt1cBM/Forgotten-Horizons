local AssetService = game:GetService("AssetService")

local ChunkGenerator = require(script.Parent.ChunkGenerator)

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new()
	local self = setmetatable({}, Chunk)

	self.Face = nil
	self.ChunkX = nil
	self.ChunkY = nil

	self.MeshPart = nil

	return self
end

function Chunk:BuildMesh()
	local EditableMesh = AssetService:CreateEditableMesh()

	ChunkGenerator.Generate(EditableMesh, self.Face, self.ChunkX, self.ChunkY)

	local MeshPart = AssetService:CreateMeshPartAsync(Content.fromObject(EditableMesh), {
		CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
	})

	--EditableMesh:Destroy()

	MeshPart.Anchored = true
	MeshPart.Parent = workspace

	return MeshPart
end

function Chunk:Generate(Face, ChunkX, ChunkY)
	self.Face = Face
	self.ChunkX = ChunkX
	self.ChunkY = ChunkY

	if self.MeshPart then
		self.MeshPart:Destroy()
	end

	self.MeshPart = self:BuildMesh()
end

function Chunk:Recycle(Face, ChunkX, ChunkY)
	self:Generate(Face, ChunkX, ChunkY)
end

return Chunk
