local Constants = require(script.Parent.Parent.Constants)

local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)
local CubeSphere = require(script.Parent.Parent.CubeSphere)
local PlayerTracker = require(script.Parent.Parent.Player.PlayerTracker)

local ChunkManager = {}

local physicalChunks = {}
local loadedLocations = {}

local currentFace = nil
local currentChunkX = nil
local currentChunkY = nil
local currentHiddenCorner = StreamPlanner.HiddenCorner.SE

local planetContext

local function locationsMatch(a, b)
	return a.face == b.face and a.chunkX == b.chunkX and a.chunkY == b.chunkY
end

local function shouldShiftChunk()
	return false
end

function ChunkManager.setCenterLocation(location)
	currentFace = location.face
	currentChunkX = location.chunkX
	currentChunkY = location.chunkY
end

function ChunkManager.initialize()
	local PlanetContext = require(script.Parent.PlanetContext)

	planetContext = PlanetContext.new({
		radius = Constants.Planet.RADIUS,
		resolution = Constants.Planet.RESOLUTION,
		center = Constants.Planet.CENTER,
		maxHeight = 200,
	})

	local currentLocation = {
		face = "+Y",
		chunkX = math.floor(planetContext.faceChunkCount / 2),
		chunkY = math.floor(planetContext.faceChunkCount / 2),
	}

	ChunkManager.setCenterLocation(currentLocation)

	local plan = StreamPlanner.getPlan(currentLocation, currentHiddenCorner)

	for _, location in ipairs(plan) do
		local chunk = Chunk.new()

		chunk:generate(planetContext, location)

		table.insert(physicalChunks, chunk)
		table.insert(loadedLocations, location)
	end
end

function ChunkManager.update(playerTracker)
	local chunkX, chunkY = CubeSphere.getChunkFromPosition(planetContext, currentFace, playerTracker.position)

	if chunkX ~= currentChunkX or chunkY ~= currentChunkY then
		warn(
			"Chunk changed:",
			chunkX,
			chunkY,
			"Current:",
			currentChunkX,
			currentChunkY,
			"Position:",
			playerTracker.position
		)

		currentChunkX = chunkX
		currentChunkY = chunkY

		local location = {
			face = currentFace,
			chunkX = currentChunkX,
			chunkY = currentChunkY,
		}
		physicalChunks[1].meshPart.Transparency = 0.5

		local plan = StreamPlanner.getPlan(location, currentHiddenCorner)
	end
end

return ChunkManager
