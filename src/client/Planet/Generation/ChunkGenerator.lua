local Constants = require(script.Parent.Parent.Constants)
local CubeSphere = require(script.Parent.Parent.CubeSphere)

local ChunkGenerator = {}

function ChunkGenerator.generate(editableMesh, faceName, chunkX, chunkY)
	local vertices = {}

	local uMin, uMax, vMin, vMax = CubeSphere.getChunkBounds(chunkX, chunkY)

	for y = 0, Constants.Planet.RESOLUTION do
		vertices[y] = {}

		for x = 0, Constants.Planet.RESOLUTION do
			local alphaX = x / Constants.Planet.RESOLUTION
			local alphaY = y / Constants.Planet.RESOLUTION

			local u = uMin + alphaX * (uMax - uMin)
			local v = vMin + alphaY * (vMax - vMin)

			local cubePoint = CubeSphere.getCubePoint(faceName, u, v)
			local normal = CubeSphere.cubeToSphere(cubePoint)

			local height = 0

			local spherePoint = Constants.Planet.CENTER + normal * (Constants.Planet.RADIUS + height)

			local vertexId = editableMesh:AddVertex(spherePoint)
			vertices[y][x] = vertexId
		end
	end

	for y = 0, Constants.Planet.RESOLUTION - 1 do
		for x = 0, Constants.Planet.RESOLUTION - 1 do
			local a = vertices[y][x]
			local b = vertices[y][x + 1]
			local c = vertices[y + 1][x]
			local d = vertices[y + 1][x + 1]

			editableMesh:AddTriangle(a, b, c)
			editableMesh:AddTriangle(b, d, c)
		end
	end
end

return ChunkGenerator
