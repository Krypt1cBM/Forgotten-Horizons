local Constants = require(script.Parent.Parent.Constants)

local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

local ChunkManager = {}

local loadedChunks = {}

local currentFace = nil
local currentChunkX = nil
local currentChunkY = nil
local currentHiddenCorner = StreamPlanner.HiddenCorner.SE

local pendingCenterLocation = nil
local pendingDesiredLocations = nil
local playerChunkX = nil
local playerChunkY = nil

local planetContext

local function reconcileChunks(centerLocation, desiredLocations)
	local missingLocations = {}
	local freeChunks = {}

	for key, desiredLocation in pairs(desiredLocations) do
		if not loadedChunks[key] then
			table.insert(missingLocations, desiredLocation)
		end
	end

	for key, chunk in pairs(loadedChunks) do
		if not desiredLocations[key] then
			table.insert(freeChunks, {
				key = key,
				chunk = chunk,
			})
		end
	end

	table.sort(missingLocations, function(a, b)
		return StreamPlanner.getLocationKey(a) < StreamPlanner.getLocationKey(b)
	end)

	table.sort(freeChunks, function(a, b)
		return a.key < b.key
	end)

	if #missingLocations ~= #freeChunks then
		warn("Streaming mismatch:", "Missing:", #missingLocations, "Free:", #freeChunks)

		for _, location in ipairs(missingLocations) do
			warn("Missing:", StreamPlanner.getLocationKey(location))
		end

		for _, freeChunk in ipairs(freeChunks) do
			warn("Free:", freeChunk.key)
		end

		return false
	end

	if #missingLocations == 0 then
		return true
	end

	if pendingCenterLocation ~= centerLocation then
		return false
	end

	local missingLocation = missingLocations[1]
	local freeChunk = freeChunks[1]

	freeChunk.chunk:recycle(planetContext, missingLocation)

	loadedChunks[freeChunk.key] = nil
	loadedChunks[StreamPlanner.getLocationKey(missingLocation)] = freeChunk.chunk

	local remainingMissing = 0

	for key in pairs(desiredLocations) do
		if not loadedChunks[key] then
			remainingMissing += 1
		end
	end

	return remainingMissing == 0
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

	local desiredLocations = StreamPlanner.getDesiredLocations(planetContext, currentLocation, currentHiddenCorner)

	for _, location in pairs(desiredLocations) do
		local chunk = Chunk.new()

		chunk:generate(planetContext, location)

		loadedChunks[StreamPlanner.getLocationKey(location)] = chunk
	end
end

function ChunkManager.update(playerTracker)
	local position = playerTracker.position

	if playerTracker.isGrounded and playerTracker.groundResult then
		position = playerTracker.groundResult.Position
	end

	local chunkX, chunkY = CubeSphere.getChunkFromPosition(planetContext, currentFace, position)

	if chunkX ~= playerChunkX or chunkY ~= playerChunkY then
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

		playerChunkX = chunkX
		playerChunkY = chunkY

		pendingCenterLocation = {
			face = currentFace,
			chunkX = chunkX,
			chunkY = chunkY,
		}

		pendingDesiredLocations =
			StreamPlanner.getDesiredLocations(planetContext, pendingCenterLocation, currentHiddenCorner)
	end

	if pendingDesiredLocations then
		local complete = reconcileChunks(pendingCenterLocation, pendingDesiredLocations)

		if complete then
			ChunkManager.setCenterLocation(pendingCenterLocation)

			pendingCenterLocation = nil
			pendingDesiredLocations = nil
		end
	end
end

return ChunkManager
