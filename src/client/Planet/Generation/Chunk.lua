local AssetService = game:GetService("AssetService")

local ChunkGenerator = require(script.Parent.ChunkGenerator)

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new()
	local self = setmetatable({}, Chunk)

	self.face = nil
	self.chunkX = nil
	self.chunkY = nil

	self.meshPart = nil

	return self
end

function Chunk:buildMesh()
	local editableMesh = AssetService:CreateEditableMesh()

	ChunkGenerator.generate(editableMesh, self.face, self.chunkX, self.chunkY)

	local meshPart = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
		CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
	})

	meshPart.Anchored = true
	meshPart.Parent = workspace

	return meshPart
end

function Chunk:generate(face, chunkX, chunkY)
	self.face = face
	self.chunkX = chunkX
	self.chunkY = chunkY

	if self.meshPart then
		self.meshPart:Destroy()
	end

	self.meshPart = self:buildMesh()
end

function Chunk:recycle(face, chunkX, chunkY)
	self:generate(face, chunkX, chunkY)
end

return Chunk
