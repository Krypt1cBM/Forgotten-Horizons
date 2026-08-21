local Constants = require(script.Parent.Parent.Constants)
local CubeTopology = require(script.Parent.CubeTopology)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

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

local function addLocation(set, context, face, chunkX, chunkY)
	local location = {
		face = face,
		chunkX = chunkX,
		chunkY = chunkY,
	}

	local wrapped = CubeTopology.wrapLocation(context, location)
	local key = StreamPlanner.getLocationKey(wrapped)

	if set[key] then
		return
	end

	set[key] = wrapped
end

function StreamPlanner.getDesiredLocations(context, centerLocation, hiddenCorner)
	local desiredLocations = {}

	for offsetY = -2, 2 do
		for offsetX = -2, 2 do
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

function StreamPlanner.getHiddenCorner(context, face, chunkX, chunkY, position)
	local direction = (position - context.center).Unit
	local cubePoint = CubeSphere.sphereToCube(face, direction)

	local chunkSize = 2 / context.faceChunkCount

	local uMin = -1 + chunkX * chunkSize
	local vMin = -1 + chunkY * chunkSize

	local localU = (cubePoint.X - uMin) / chunkSize
	local localV = (cubePoint.Y - vMin) / chunkSize

	local isRight = localU >= 0.5
	local isTop = localV >= 0.5

	local hiddenCorner

	if isTop then
		if isRight then
			hiddenCorner = StreamPlanner.HiddenCorner.SW
		else
			hiddenCorner = StreamPlanner.HiddenCorner.SE
		end
	else
		if isRight then
			hiddenCorner = StreamPlanner.HiddenCorner.NW
		else
			hiddenCorner = StreamPlanner.HiddenCorner.NE
		end
	end

	return hiddenCorner
end

function StreamPlanner.getHiddenCornerWithHysteresis(context, face, chunkX, chunkY, position, currentHiddenCorner)
	local direction = (position - context.center).Unit
	local cubePoint = CubeSphere.sphereToCube(face, direction)

	local chunkSize = 2 / context.faceChunkCount

	local uMin = -1 + chunkX * chunkSize
	local vMin = -1 + chunkY * chunkSize

	local localU = (cubePoint.X - uMin) / chunkSize
	local localV = (cubePoint.Y - vMin) / chunkSize

	local isRight = currentHiddenCorner == StreamPlanner.HiddenCorner.SW
		or currentHiddenCorner == StreamPlanner.HiddenCorner.NW

	local isTop = currentHiddenCorner == StreamPlanner.HiddenCorner.SW
		or currentHiddenCorner == StreamPlanner.HiddenCorner.SE

	if isRight then
		if localU <= 0.5 - Constants.Planet.CORNER_HYSTERESIS then
			isRight = false
		end
	else
		if localU >= 0.5 + Constants.Planet.CORNER_HYSTERESIS then
			isRight = true
		end
	end

	if isTop then
		if localV <= 0.5 - Constants.Planet.CORNER_HYSTERESIS then
			isTop = false
		end
	else
		if localV >= 0.5 + Constants.Planet.CORNER_HYSTERESIS then
			isTop = true
		end
	end

	if isTop then
		if isRight then
			return StreamPlanner.HiddenCorner.SW
		else
			return StreamPlanner.HiddenCorner.SE
		end
	else
		if isRight then
			return StreamPlanner.HiddenCorner.NW
		else
			return StreamPlanner.HiddenCorner.NE
		end
	end
end

return StreamPlanner
