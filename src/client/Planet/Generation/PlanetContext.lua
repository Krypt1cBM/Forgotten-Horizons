local Constants = require(script.Parent.Parent.Constants)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

local PlanetContext = {}
PlanetContext.__index = PlanetContext

function PlanetContext.new(settings)
	local self = setmetatable({}, PlanetContext)

	self.baseRadius = settings.radius
	self.center = settings.center
	self.resolution = settings.resolution
	self.maxHeight = settings.maxHeight

	local maxRadius = self.baseRadius + self.maxHeight
	local faceWidth = maxRadius * 2

	local distortionFactor = CubeSphere.getDistortionFactor()
	local maxChunkSize = Constants.Planet.MAX_MESH_SIZE / distortionFactor

	self.faceChunkCount = math.ceil(faceWidth / maxChunkSize)
	self.chunkSize = faceWidth / self.faceChunkCount

	return self
end

return PlanetContext
