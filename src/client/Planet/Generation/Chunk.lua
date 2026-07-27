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
	--local editableMesh = AssetService:CreateEditableMesh()
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

function Chunk:generate(context, location)
	self.location = location
	self.chunkFrame = CubeSphere.getChunkFrame(context, location.face, location.chunkX, location.chunkY)

	if self.meshPart then
		self.meshPart:Destroy()
		self.meshPart = nil
	end
	if self.editableMesh then
		self.editableMesh:Destroy()
		self.editableMesh = nil
	end

	self.meshPart, self.editableMesh = self:buildMesh(context)
end

function Chunk:recycle(context, location)
	self:generate(context, location)
end

function Chunk:getLocation()
	return self.location
end

return Chunk
