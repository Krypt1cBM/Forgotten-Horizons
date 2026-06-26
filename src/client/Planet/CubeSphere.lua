local Constants = require(script.Parent.Constants)

local CubeSphere = {}

function CubeSphere.CubeToSphere(v)
	local x = v.X
	local y = v.Y
	local z = v.Z

	local x2 = x * x
	local y2 = y * y
	local z2 = z * z

	return Vector3.new(
		x * math.sqrt(1 - y2 / 2 - z2 / 2 + (y2 * z2) / 3),
		y * math.sqrt(1 - x2 / 2 - z2 / 2 + (x2 * z2) / 3),
		z * math.sqrt(1 - x2 / 2 - y2 / 2 + (x2 * y2) / 3)
	)
end

function CubeSphere.GetChunkBounds(ChunkX, ChunkY)
	local ChunkSize = 2 / Constants.ChunksPerFace

	local uMin = -1 + ChunkX * ChunkSize
	local uMax = uMin + ChunkSize

	local vMin = -1 + ChunkY * ChunkSize
	local vMax = vMin + ChunkSize

	return uMin, uMax, vMin, vMax
end

function CubeSphere.GetCubePoint(FaceName, u, v)
	local Face = Constants.Faces[FaceName]
	return Face.Normal + Face.Right * u + Face.Up * v
end

return CubeSphere
