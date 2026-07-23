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

function CubeSphere.getChunkBounds(context, chunkX, chunkY)
	local chunkSize = 2 / context.faceChunkCount

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

function CubeSphere.getChunkFrame(context, face, chunkX, chunkY)
	local uMin, uMax, vMin, vMax = CubeSphere.getChunkBounds(context, chunkX, chunkY)

	local u = (uMin + uMax) * 0.5
	local v = (vMin + vMax) * 0.5

	local cubePoint = CubeSphere.getCubePoint(face, u, v)
	local direction = CubeSphere.cubeToSphere(cubePoint).Unit
	local position = context.center + direction * context.baseRadius

	local up = direction

	local referenceUp = math.abs(up:Dot(Vector3.yAxis)) > 0.99 and Vector3.xAxis or Vector3.yAxis

	local right = referenceUp:Cross(up).Unit
	local forward = up:Cross(right).Unit

	return CFrame.fromMatrix(position, right, up, -forward)
end

function CubeSphere.getDistortionFactor()
	return math.sqrt(3)
end

return CubeSphere
