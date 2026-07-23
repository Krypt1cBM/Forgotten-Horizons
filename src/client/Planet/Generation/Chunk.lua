local AssetService = game:GetService("AssetService")

local ChunkGenerator = require(script.Parent.ChunkGenerator)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

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

function Chunk:buildMesh(context)
	local editableMesh = AssetService:CreateEditableMesh()

	ChunkGenerator.generate(editableMesh, context, self.location, self.chunkFrame)

	local meshPart = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
		CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
	})

	meshPart.CFrame = self.chunkFrame

	meshPart.Anchored = true
	meshPart.Parent = workspace

	return meshPart
end

function Chunk:generate(context, location)
	self.location = location
	self.chunkFrame = CubeSphere.getChunkFrame(context, location.face, location.chunkX, location.chunkY)

	if self.meshPart then
		self.meshPart:Destroy()
	end

	self.meshPart = self:buildMesh(context)
end

function Chunk:recycle(face, chunkX, chunkY)
	self:generate(face, chunkX, chunkY)
end

return Chunk
