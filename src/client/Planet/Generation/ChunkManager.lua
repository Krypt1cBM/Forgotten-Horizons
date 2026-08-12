local Constants = require(script.Parent.Parent.Constants)
local MathUtils = require(game.ReplicatedStorage.Scripts.MathUtils)

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
local playerFace = nil

local protectedBoundary = nil

local planetContext

local function locationsEqual(a, b)
	return a and b and a.face == b.face and a.chunkX == b.chunkX and a.chunkY == b.chunkY
end

local function sameBoundary(fromA, toA, fromB, toB)
	return (locationsEqual(fromA, fromB) and locationsEqual(toA, toB))
		or (locationsEqual(fromA, toB) and locationsEqual(toA, fromB))
end

local function pastMid(position, location)
	local direction = (position - planetContext.center).Unit
	local cubePoint = CubeSphere.sphereToCube(location.face, direction)

	local chunkSize = 2 / planetContext.faceChunkCount

	local uMin = -1 + location.chunkX * chunkSize
	local vMin = -1 + location.chunkY * chunkSize

	local localU = (cubePoint.X - uMin) / chunkSize
	local localV = (cubePoint.Y - vMin) / chunkSize

	if protectedBoundary.from.chunkX ~= protectedBoundary.to.chunkX then
		local positive = protectedBoundary.to.chunkX > protectedBoundary.from.chunkX

		if locationsEqual(location, protectedBoundary.to) then
			return positive and localU >= 0.5 or localU <= 0.5
		else
			return positive and localU <= 0.5 or localU >= 0.5
		end
	end

	local positive = protectedBoundary.to.chunkY > protectedBoundary.from.chunkY

	if locationsEqual(location, protectedBoundary.to) then
		return positive and localV >= 0.5 or localV <= 0.5
	end

	return positive and localV <= 0.5 or localV >= 0.5
end

local function hasCrossedChunkHysteresis(position, face, newChunkX, newChunkY, currentChunkX, currentChunkY)
	local direction = (position - planetContext.center).Unit
	local cubePoint = CubeSphere.sphereToCube(face, direction)

	local chunkSize = 2 / planetContext.faceChunkCount

	local uMin = -1 + newChunkX * chunkSize
	local vMin = -1 + newChunkY * chunkSize

	local localU = (cubePoint.X - uMin) / chunkSize
	local localV = (cubePoint.Y - vMin) / chunkSize

	local threshold = Constants.Planet.CHUNK_HYSTERESIS

	if newChunkX ~= currentChunkX then
		if newChunkX > currentChunkX then
			return localU > threshold
		else
			return localU < 1 - threshold
		end
	end

	if newChunkY ~= currentChunkY then
		if newChunkY > currentChunkY then
			return localV > threshold
		else
			return localV < 1 - threshold
		end
	end

	return true
end

local function getLoadedCount()
	local count = 0

	for _ in pairs(loadedChunks) do
		count += 1
	end

	return count
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

	loadedChunks[oldKey] = nil
	loadedChunks[newKey] = freeChunk.chunk

	freeChunk.chunk:recycle(planetContext, missingLocation)

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

	local chunkChanged = newFace ~= playerFace or chunkX ~= playerChunkX or chunkY ~= playerChunkY
	local hiddenCornerChanged = newHiddenCorner ~= currentHiddenCorner
	local acceptChunkChange = true

	local proposedLocation = {
		face = newFace,
		chunkX = chunkX,
		chunkY = chunkY,
	}

	local currentLocation = nil

	if playerFace and playerChunkX and playerChunkY then
		currentLocation = {
			face = playerFace,
			chunkX = playerChunkX,
			chunkY = playerChunkY,
		}
	end

	if currentLocation and protectedBoundary and not chunkChanged then
		if pastMid(position, currentLocation) then
			protectedBoundary = nil
		end
	end

	local isProtectedBoundary = false

	if currentLocation and protectedBoundary then
		isProtectedBoundary =
			sameBoundary(currentLocation, proposedLocation, protectedBoundary.from, protectedBoundary.to)
	end

	if chunkChanged and currentLocation and isProtectedBoundary then
		acceptChunkChange = hasCrossedChunkHysteresis(position, newFace, chunkX, chunkY, playerChunkX, playerChunkY)
	end

	if chunkChanged and acceptChunkChange then
		if playerFace ~= nil and not isProtectedBoundary then
			protectedBoundary = {
				from = {
					face = playerFace,
					chunkX = playerChunkX,
					chunkY = playerChunkY,
				},

				to = {
					face = newFace,
					chunkX = chunkX,
					chunkY = chunkY,
				},
			}
		end

		playerFace = newFace
		playerChunkX = chunkX
		playerChunkY = chunkY
		currentHiddenCorner = newHiddenCorner

		pendingCenterLocation = {
			face = playerFace,
			chunkX = playerChunkX,
			chunkY = playerChunkY,
		}

		pendingDesiredLocations =
			StreamPlanner.getDesiredLocations(planetContext, pendingCenterLocation, currentHiddenCorner)
	elseif not chunkChanged and hiddenCornerChanged and currentLocation then
		currentHiddenCorner = newHiddenCorner

		pendingCenterLocation = currentLocation

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
