local Constants = require(script.Parent.Parent.Constants)

local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)
local CubeSphere = require(script.Parent.Parent.CubeSphere)
local CubeTopology = require(script.Parent.CubeTopology)

local ChunkManager = {}

local loadedChunks = {}

local currentFace = nil
local currentHiddenCorner = StreamPlanner.HiddenCorner.SE

local pendingCenterLocation = nil
local pendingDesiredLocations = nil
local playerChunkX = nil
local playerChunkY = nil

local planetContext

local function locationsEqual(a, b)
	return a and b and a.face == b.face and a.chunkX == b.chunkX and a.chunkY == b.chunkY
end

local function reconcileChunks(centerLocation, desiredLocations)
	local commonChunks = {}
	local freeChunks = {}
	local missingLocations = {}

	for key, chunk in pairs(loadedChunks) do
		if desiredLocations[key] then
			table.insert(commonChunks, {
				key = key,
				chunk = chunk,
			})
		else
			table.insert(freeChunks, {
				key = key,
				chunk = chunk,
			})
		end
	end

	for key, location in pairs(desiredLocations) do
		if not loadedChunks[key] then
			table.insert(missingLocations, location)
		end
	end

	table.sort(freeChunks, function(a, b)
		return a.key < b.key
	end)

	table.sort(missingLocations, function(a, b)
		return StreamPlanner.getLocationKey(a) < StreamPlanner.getLocationKey(b)
	end)

	if #freeChunks ~= #missingLocations then
		warn("Streaming mismatch:", "Common:", #commonChunks, "Free:", #freeChunks, "Missing:", #missingLocations)

		return false
	end

	if #missingLocations == 0 then
		return true
	end

	if not locationsEqual(pendingCenterLocation, centerLocation) then
		return false
	end

	local freeChunk = freeChunks[1]
	local missingLocation = missingLocations[1]

	local oldKey = freeChunk.key
	local newKey = StreamPlanner.getLocationKey(missingLocation)

	freeChunk.chunk:recycle(planetContext, missingLocation)

	loadedChunks[oldKey] = nil
	loadedChunks[newKey] = freeChunk.chunk

	return false
end

function ChunkManager.setCenterLocation(location)
	currentFace = location.face
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

	local newFace = CubeTopology.getFaceFromPosition(planetContext, position)

	local chunkX, chunkY = CubeSphere.getChunkFromPosition(planetContext, newFace, position)

	local newHiddenCorner = StreamPlanner.getHiddenCorner(planetContext, newFace, chunkX, chunkY, position)

	if
		newFace ~= currentFace
		or chunkX ~= playerChunkX
		or chunkY ~= playerChunkY
		or newHiddenCorner ~= currentHiddenCorner
	then
		playerChunkX = chunkX
		playerChunkY = chunkY
		currentHiddenCorner = newHiddenCorner

		pendingCenterLocation = {
			face = newFace,
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
