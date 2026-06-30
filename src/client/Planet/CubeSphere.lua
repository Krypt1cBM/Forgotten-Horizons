local Constants = require(script.Parent.Constants)

local CubeSphere = {}

function CubeSphere.cubeToSphere(v)
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

function CubeSphere.getChunkBounds(chunkX, chunkY)
	local chunkSize = 2 / Constants.Planet.ChunksPerFace

	local uMin = -1 + chunkX * chunkSize
	local uMax = uMin + chunkSize

	local vMin = -1 + chunkY * chunkSize
	local vMax = vMin + chunkSize

	return uMin, uMax, vMin, vMax
end

function CubeSphere.getCubePoint(faceName, u, v)
	local face = Constants.Faces[faceName]

	return face.Normal + face.Right * u + face.Up * v
end

return CubeSphere
