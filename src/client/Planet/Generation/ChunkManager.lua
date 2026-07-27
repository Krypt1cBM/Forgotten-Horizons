local Constants = require(script.Parent.Parent.Constants)

local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)
local CubeSphere = require(script.Parent.Parent.CubeSphere)
local PlayerTracker = require(script.Parent.Parent.Player.PlayerTracker)

local ChunkManager = {}

local loadedChunks = {}

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

local function locationKey(location)
	return location.face .. ":" .. location.chunkX .. ":" .. location.chunkY
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

		loadedChunks[locationKey(location)] = chunk
	end
end

function ChunkManager.update(playerTracker)
	local position = playerTracker.position

	if playerTracker.isGrounded and playerTracker.groundResult then
		position = playerTracker.groundResult.Position
	end

	local chunkX, chunkY = CubeSphere.getChunkFromPosition(planetContext, currentFace, position)

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

		local plan = StreamPlanner.getPlan(location, currentHiddenCorner)

		local desiredLocations = {}
		for _, desiredLocation in ipairs(plan) do
			desiredLocations[locationKey(desiredLocation)] = desiredLocation
		end

		local missingLocations = {}

		for key, desiredLocation in pairs(desiredLocations) do
			if not loadedChunks[key] then
				table.insert(missingLocations, desiredLocation)
			end
		end

		local freeChunks = {}

		for key, chunk in pairs(loadedChunks) do
			if not desiredLocations[key] then
				table.insert(freeChunks, {
					key = key,
					chunk = chunk,
				})
			end
		end

		assert(#missingLocations == #freeChunks, "Streaming mismatch: missing locations do not match free chunks")

		for i, missingLocation in ipairs(missingLocations) do
			local freeChunk = freeChunks[i]

			loadedChunks[freeChunk.key] = nil
			freeChunk.chunk:recycle(planetContext, missingLocation)
			loadedChunks[locationKey(missingLocation)] = freeChunk.chunk
		end
	end
end

return ChunkManager
