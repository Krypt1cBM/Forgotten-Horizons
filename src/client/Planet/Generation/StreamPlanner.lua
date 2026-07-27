local StreamPlanner = {}

StreamPlanner.HiddenCorner = {
	NW = 1,
	NE = 2,
	SW = 3,
	SE = 4,
}

local cornerOffsets = {
	[StreamPlanner.HiddenCorner.NW] = Vector2.new(-1, 1),
	[StreamPlanner.HiddenCorner.NE] = Vector2.new(1, 1),
	[StreamPlanner.HiddenCorner.SW] = Vector2.new(-1, -1),
	[StreamPlanner.HiddenCorner.SE] = Vector2.new(1, -1),
}

function StreamPlanner.getLocationKey(location)
	return location.face .. ":" .. location.chunkX .. ":" .. location.chunkY
end

local function isValidLocation(context, location)
	return location.chunkX >= 0
		and location.chunkX < context.faceChunkCount
		and location.chunkY >= 0
		and location.chunkY < context.faceChunkCount
end

local function addLocation(set, context, face, chunkX, chunkY)
	local location = {
		face = face,
		chunkX = chunkX,
		chunkY = chunkY,
	}

	if isValidLocation(context, location) then
		set[StreamPlanner.getLocationKey(location)] = location
	end
end

function StreamPlanner.getDesiredLocations(context, centerLocation, hiddenCorner)
	local desiredLocations = {}
	local hidden = cornerOffsets[hiddenCorner]

	for offsetY = -1, 1 do
		for offsetX = -1, 1 do
			if offsetX == hidden.X and offsetY == hidden.Y then
				continue
			end

			addLocation(
				desiredLocations,
				context,
				centerLocation.face,
				centerLocation.chunkX + offsetX,
				centerLocation.chunkY + offsetY
			)
		end
	end

	return desiredLocations
end

return StreamPlanner
