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

function CubeSphere.sphereToCube(faceName, direction)
	local face = Constants.Faces[faceName]

	local function toDirection(u, v)
		local cubePoint = face.Normal + face.Right * u + face.Up * v
		return CubeSphere.cubeToSphere(cubePoint).Unit
	end

	local normalDot = math.max(direction:Dot(face.Normal), 1e-6)
	local u = direction:Dot(face.Right) / normalDot
	local v = direction:Dot(face.Up) / normalDot

	for _ = 1, 5 do
		local currentDirection = toDirection(u, v)
		local delta = currentDirection - direction

		if delta.Magnitude < 1e-6 then
			break
		end

		local step = 1e-4

		local directionUForward = toDirection(u + step, v)
		local directionUBackward = toDirection(u - step, v)
		local directionVForward = toDirection(u, v + step)
		local directionVBackward = toDirection(u, v - step)

		local derivativeU = (directionUForward - directionUBackward) / (2 * step)
		local derivativeV = (directionVForward - directionVBackward) / (2 * step)

		local uu = derivativeU:Dot(derivativeU)
		local uv = derivativeU:Dot(derivativeV)
		local vv = derivativeV:Dot(derivativeV)

		local du = delta:Dot(derivativeU)
		local dv = delta:Dot(derivativeV)

		local determinant = uu * vv - uv * uv
		if math.abs(determinant) < 1e-9 then
			break
		end

		local offsetU = (du * vv - dv * uv) / determinant
		local offsetV = (dv * uu - du * uv) / determinant

		u -= offsetU
		v -= offsetV
	end

	return Vector3.new(u, v, 0)
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

function CubeSphere.getChunkFromPosition(context, faceName, position)
	local direction = (position - context.center).Unit
	local cubePoint = CubeSphere.sphereToCube(faceName, direction)

	local normalizedU = (cubePoint.X + 1) * 0.5
	local normalizedV = (cubePoint.Y + 1) * 0.5

	local chunkX = math.clamp(math.floor(normalizedU * context.faceChunkCount), 0, context.faceChunkCount - 1)
	local chunkY = math.clamp(math.floor(normalizedV * context.faceChunkCount), 0, context.faceChunkCount - 1)

	return chunkX, chunkY
end

function CubeSphere.getDistortionFactor()
	return math.sqrt(3)
end

return CubeSphere
