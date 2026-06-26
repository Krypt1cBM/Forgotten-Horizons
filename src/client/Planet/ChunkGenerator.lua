local Constants = require(script.Parent.Constants)
local CubeSphere = require(script.Parent.CubeSphere)
local ChunkGenerator = {}

function ChunkGenerator.Generate(EditableMesh, FaceName, ChunkX, ChunkY)
	local Vertices = {}

	local uMin, uMax, vMin, vMax = CubeSphere.GetChunkBounds(ChunkX, ChunkY, Constants.ChunksPerFace)

	for y = 0, Constants.RESOLUTION do
		Vertices[y] = {}

		for x = 0, Constants.RESOLUTION do
			local alphaX = x / Constants.RESOLUTION
			local alphaY = y / Constants.RESOLUTION

			local u = uMin + alphaX * (uMax - uMin)
			local v = vMin + alphaY * (vMax - vMin)

			local CubePoint = CubeSphere.GetCubePoint(FaceName, u, v)
			local Normal = CubeSphere.CubeToSphere(CubePoint)

			local Height = 0

			local SpherePoint = Constants.PLANET_CENTER + Normal * (Constants.RADIUS + Height)

			local VertexId = EditableMesh:AddVertex(SpherePoint)
			Vertices[y][x] = VertexId
		end
	end

	for y = 0, Constants.RESOLUTION - 1 do
		for x = 0, Constants.RESOLUTION - 1 do
			local a = Vertices[y][x]
			local b = Vertices[y][x + 1]
			local c = Vertices[y + 1][x]
			local d = Vertices[y + 1][x + 1]

			EditableMesh:AddTriangle(a, b, c)
			EditableMesh:AddTriangle(b, d, c)
		end
	end
end

return ChunkGenerator
