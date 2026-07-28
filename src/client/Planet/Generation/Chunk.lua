local AssetService = game:GetService("AssetService")

local ChunkGenerator = require(script.Parent.ChunkGenerator)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new()
	local self = setmetatable({}, Chunk)

	self.location = nil
	self.face = nil
	self.chunkX = nil
	self.chunkY = nil

	self.meshPart = nil
	self.editableMesh = nil

	return self
end

function Chunk:buildMesh(context)
	local success1, editableMesh = pcall(function()
		return AssetService:CreateEditableMesh()
	end)
	assert(success1 and editableMesh, "Failed to create EditableMesh during chunk recycle")

	ChunkGenerator.generate(editableMesh, context, self.location, self.chunkFrame)

	local success2, result = pcall(function()
		return AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
			CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
		})
	end)

	if not success2 then
		error(result)
	end
	local meshPart = result

	meshPart.CFrame = self.chunkFrame

	meshPart.Anchored = true
	meshPart.Parent = workspace

	return meshPart, editableMesh
end

function Chunk:clearMesh()
	if self.meshPart then
		self.meshPart:Destroy()
		self.meshPart = nil
	end

	if self.editableMesh then
		self.editableMesh:Destroy()
		self.editableMesh = nil
	end
end

function Chunk:generate(context, location)
	self.location = location
	self.chunkFrame = CubeSphere.getChunkFrame(context, location.face, location.chunkX, location.chunkY)

	self:clearMesh()

	self.meshPart, self.editableMesh = self:buildMesh(context)

	self.meshPart.Name = self.location.face .. ":" .. self.location.chunkX .. ":" .. self.location.chunkY
end

function Chunk:recycle(context, location)
	self.location = location
	self.chunkFrame = CubeSphere.getChunkFrame(context, location.face, location.chunkX, location.chunkY)

	local faces = self.editableMesh:GetFaces()

	for _, faceId in ipairs(faces) do
		self.editableMesh:RemoveFace(faceId)
	end

	self.editableMesh:RemoveUnused()

	ChunkGenerator.generate(self.editableMesh, context, location, self.chunkFrame)

	local success, updatedMeshPart = pcall(function()
		return AssetService:CreateMeshPartAsync(Content.fromObject(self.editableMesh), {
			CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
		})
	end)

	assert(success and updatedMeshPart, "Failed to create updated MeshPart during chunk recycle")

	updatedMeshPart.Name = "TEST_UPDATED_MESH"
	updatedMeshPart.CFrame = self.chunkFrame
	updatedMeshPart.Parent = workspace

	self.meshPart.CFrame = self.chunkFrame
end

function Chunk:getLocation()
	return self.location
end

return Chunk
