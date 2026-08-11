local Constants = require(script.Parent.Parent.Constants)

local CubeTopology = {}

CubeTopology.Edge = {
	Left = "Left",
	Right = "Right",
	Down = "Down",
	Up = "Up",
}

local function findFaceByNormal(normal)
	for name, face in pairs(Constants.Faces) do
		if face.Normal == normal then
			return name
		end
	end

	error("No face found for normal " .. tostring(normal))
end

function CubeTopology.getNeighborFace(faceName, edge)
	local face = Constants.Faces[faceName]

	local direction

	if edge == CubeTopology.Edge.Right then
		direction = face.Right
	elseif edge == CubeTopology.Edge.Left then
		direction = -face.Right
	elseif edge == CubeTopology.Edge.Up then
		direction = face.Up
	elseif edge == CubeTopology.Edge.Down then
		direction = -face.Up
	end

	return findFaceByNormal(direction)
end

function CubeTopology.getEdgeDirection(faceName, edge)
	local face = Constants.Faces[faceName]

	if edge == CubeTopology.Edge.Left or edge == CubeTopology.Edge.Right then
		return face.Up
	else
		return face.Right
	end
end

function CubeTopology.getOppositeEdge(faceName, neighborFaceName)
	local face = Constants.Faces[faceName]
	local neighborFace = Constants.Faces[neighborFaceName]

	local direction = face.Normal

	if neighborFace.Right == direction then
		return CubeTopology.Edge.Right
	elseif -neighborFace.Right == direction then
		return CubeTopology.Edge.Left
	elseif neighborFace.Up == direction then
		return CubeTopology.Edge.Up
	elseif -neighborFace.Up == direction then
		return CubeTopology.Edge.Down
	end

	error("No opposite edge found for face " .. faceName .. " and neighbor face " .. neighborFaceName)
end

function CubeTopology.getOutOfBoundsEdge(context, location)
	if location.chunkX < 0 then
		return CubeTopology.Edge.Left
	elseif location.chunkX >= context.faceChunkCount then
		return CubeTopology.Edge.Right
	elseif location.chunkY < 0 then
		return CubeTopology.Edge.Down
	elseif location.chunkY >= context.faceChunkCount then
		return CubeTopology.Edge.Up
	end

	return nil
end

function CubeTopology.isOutOfBounds(context, location)
	return location.chunkX < 0
		or location.chunkX >= context.faceChunkCount
		or location.chunkY < 0
		or location.chunkY >= context.faceChunkCount
end

function CubeTopology.shouldFlipCoordinate(faceName, edge, neighborFaceName, neighborEdge)
	local currentDirection = CubeTopology.getEdgeDirection(faceName, edge)
	local neighborDirection = CubeTopology.getEdgeDirection(neighborFaceName, neighborEdge)

	return currentDirection == -neighborDirection
end

function CubeTopology.wrapLocation(context, location)
	local result = {
		face = location.face,
		chunkX = location.chunkX,
		chunkY = location.chunkY,
	}

	while CubeTopology.isOutOfBounds(context, result) do
		local edge = CubeTopology.getOutOfBoundsEdge(context, result)

		local neighborFace = CubeTopology.getNeighborFace(result.face, edge)

		local neighborEdge = CubeTopology.getOppositeEdge(result.face, neighborFace)

		local max = context.faceChunkCount - 1

		local edgeCoordinate

		if edge == CubeTopology.Edge.Left or edge == CubeTopology.Edge.Right then
			edgeCoordinate = result.chunkY
		else
			edgeCoordinate = result.chunkX
		end

		if CubeTopology.shouldFlipCoordinate(result.face, edge, neighborFace, neighborEdge) then
			edgeCoordinate = max - edgeCoordinate
		end

		if neighborEdge == CubeTopology.Edge.Left then
			result.chunkX = 0
			result.chunkY = edgeCoordinate
		elseif neighborEdge == CubeTopology.Edge.Right then
			result.chunkX = max
			result.chunkY = edgeCoordinate
		elseif neighborEdge == CubeTopology.Edge.Down then
			result.chunkY = 0
			result.chunkX = edgeCoordinate
		elseif neighborEdge == CubeTopology.Edge.Up then
			result.chunkY = max
			result.chunkX = edgeCoordinate
		end

		result.face = neighborFace
	end

	return result
end

function CubeTopology.getFaceFromPosition(context, position)
	local direction = (position - context.center).Unit

	local bestFace = nil
	local bestDot = -math.huge

	for faceName, face in pairs(Constants.Faces) do
		local dot = direction:Dot(face.Normal)

		if dot > bestDot then
			bestDot = dot
			bestFace = faceName
		end
	end

	return bestFace
end

return CubeTopology
