local CubeSphere = require(script.Parent.Parent.CubeSphere)

local ChunkGenerator = {}

function ChunkGenerator.createTopology(editableMesh, context)
	local vertices = {}

	for y = 0, context.resolution do
		vertices[y] = {}
		for x = 0, context.resolution do
			vertices[y][x] = editableMesh:AddVertex(Vector3.zero)
		end
	end

	for y = 0, context.resolution - 1 do
		for x = 0, context.resolution - 1 do
			local a = vertices[y][x]
			local b = vertices[y][x + 1]
			local c = vertices[y + 1][x]
			local d = vertices[y + 1][x + 1]

			editableMesh:AddTriangle(a, b, c)
			editableMesh:AddTriangle(b, d, c)
		end
	end

	return vertices
end

function ChunkGenerator.updatePositions(editableMesh, context, location, chunkFrame, vertices)
	local uMin, uMax, vMin, vMax = CubeSphere.getChunkBounds(context, location.chunkX, location.chunkY)

	for y = 0, context.resolution do
		for x = 0, context.resolution do
			local alphaX = x / context.resolution
			local alphaY = y / context.resolution

			local u = uMin + alphaX * (uMax - uMin)
			local v = vMin + alphaY * (vMax - vMin)

			local cubePoint = CubeSphere.getCubePoint(location.face, u, v)

			local direction = CubeSphere.cubeToSphere(cubePoint).Unit

			local height = math.noise(direction.X * 3, direction.Y * 3, direction.Z * 3) * context.maxHeight
			height = 0 --no terrain

			local spherePoint = direction * (context.baseRadius + height)
			local localPoint = chunkFrame:PointToObjectSpace(spherePoint)

			editableMesh:SetPosition(vertices[y][x], localPoint)
		end
	end
end

return ChunkGenerator
