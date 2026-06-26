--local Chunk = require(script.Parent.Chunk)
local Constants = require(script.Parent.Constants)

local PlayerTracker = {}

function PlayerTracker.GetCurrentChunk(WorldPosition)
	local Normal = WorldPosition.Unit

	local AbsX = math.abs(Normal.X)
	local AbsY = math.abs(Normal.Y)
	local AbsZ = math.abs(Normal.Z)

	local FaceName
	local Face

	local u
	local v

	if AbsX >= AbsY and AbsX >= AbsZ then
		if Normal.X >= 0 then
			FaceName = "+X"
		else
			FaceName = "-X"
		end
	elseif AbsY >= AbsX and AbsY >= AbsZ then
		if Normal.Y >= 0 then
			FaceName = "+Y"
		else
			FaceName = "-Y"
		end
	else
		if Normal.Z >= 0 then
			FaceName = "+Z"
		else
			FaceName = "-Z"
		end
	end

	Face = Constants.Faces[FaceName]

	local CubePoint = Normal / math.max(AbsX, AbsY, AbsZ)

	u = CubePoint:Dot(Face.Right)
	v = CubePoint:Dot(Face.Up)

	local ChunkSize = 2 / Constants.ChunksPerFace

	local ChunkX = math.clamp(math.floor((u + 1) / ChunkSize), 0, Constants.ChunksPerFace - 1)

	local ChunkY = math.clamp(math.floor((v + 1) / ChunkSize), 0, Constants.ChunksPerFace - 1)

	return FaceName, ChunkX, ChunkY
end

return PlayerTracker
