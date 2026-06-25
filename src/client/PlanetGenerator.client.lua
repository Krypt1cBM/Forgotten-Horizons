--REFERENCES--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local Seed = ReplicatedStorage:WaitForChild("PlanetSeed").Value

local Random = Random.new(Seed)

local MAX_MESH_SIZE = 2048 * 0.98

--PLANET VARS--
--Data
local PlanetData = {
	Seed = Seed,

	Radius = Random:NextInteger(80, 150),

	BaseScale = Random:NextNumber(1.5, 3),
	DetailScale = Random:NextNumber(6, 12),

	MountainMaskScale = Random:NextNumber(0.4, 1.2),
	MountainScale = Random:NextNumber(2, 6),

	BaseHeight = Random:NextNumber(6, 12),
	DetailHeight = Random:NextNumber(1, 4),
	MountainHeight = Random:NextNumber(20, 60),
}

PlanetData.Radius = 2000
PlanetData.BaseScale = 2
PlanetData.MountainMaskScale = 0.8

--Faces
local Faces = {
	{
		Name = "+X",
		Normal = Vector3.new(1, 0, 0),
		Right = Vector3.new(0, 0, -1),
		Up = Vector3.new(0, 1, 0),
	},
	{
		Name = "-X",
		Normal = Vector3.new(-1, 0, 0),
		Right = Vector3.new(0, 0, 1),
		Up = Vector3.new(0, 1, 0),
	},
	{
		Name = "+Y",
		Normal = Vector3.new(0, 1, 0),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 0, -1),
	},
	{
		Name = "-Y",
		Normal = Vector3.new(0, -1, 0),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 0, 1),
	},
	{
		Name = "+Z",
		Normal = Vector3.new(0, 0, 1),
		Right = Vector3.new(1, 0, 0),
		Up = Vector3.new(0, 1, 0),
	},
	{
		Name = "-Z",
		Normal = Vector3.new(0, 0, -1),
		Right = Vector3.new(-1, 0, 0),
		Up = Vector3.new(0, 1, 0),
	},
}

--Resolution
local FaceResolution = 32

local refRadius = 900
local refResolution = 32
local function UpdateResolution()
	local resolution = math.floor(refResolution * PlanetData.Radius / refRadius)

	FaceResolution = math.min(resolution, 64)
end
UpdateResolution()

--Colors
local OceanColorId = Color3.fromRGB(30, 100, 220)
local LandColorId = Color3.fromRGB(120, 200, 80)
local CONTINENT_THRESHOLD = 0.5

--SEED--
local SeedX = Seed * 1.731
local SeedY = Seed * 2.913
local SeedZ = Seed * 4.127

--FUNCTIONS--
--Height Functions
local function BaseHeight(Normal)
	local n = math.noise(
		Normal.X * PlanetData.BaseScale + SeedX,
		Normal.Y * PlanetData.BaseScale + SeedY,
		Normal.Z * PlanetData.BaseScale + SeedZ
	)
	return n * PlanetData.BaseHeight
end

local function DetailHeight(Normal)
	local n = math.noise(
		Normal.X * PlanetData.DetailScale + SeedX,
		Normal.Y * PlanetData.DetailScale + SeedY,
		Normal.Z * PlanetData.DetailScale + SeedZ
	)
	return n * PlanetData.DetailHeight
end

local function ContinentMask(Normal)
	local continentScale = PlanetData.BaseScale * 0.2

	local large = (
		math.noise(
			Normal.X * continentScale + SeedX,
			Normal.Y * continentScale + SeedY,
			Normal.Z * continentScale + SeedZ
		) + 1
	) * 0.5

	local small = (math.noise(Normal.X * 1.3 + SeedX, Normal.Y * 1.3 + SeedY, Normal.Z * 1.3 + SeedZ) + 1) * 0.5

	local c = large * 0.7 + small * 0.3

	return c
end

local function GetTerrainData(Normal)
	local continent = ContinentMask(Normal)

	return {
		Continent = continent,
		IsLand = continent > CONTINENT_THRESHOLD,
	}
end

local function CliffHeight(Normal, continent)
	local mask = 1 - math.abs(continent * 2 - 1)
	return mask * PlanetData.Radius * 0.03
end

local function MountainHeight(Normal)
	local mask = (
		math.noise(
			Normal.X * PlanetData.MountainMaskScale + SeedX,
			Normal.Y * PlanetData.MountainMaskScale + SeedY,
			Normal.Z * PlanetData.MountainMaskScale + SeedZ
		) + 1
	) * 0.5

	local n = math.noise(
		Normal.X * PlanetData.MountainScale + SeedX,
		Normal.Y * PlanetData.MountainScale + SeedY,
		Normal.Z * PlanetData.MountainScale + SeedZ
	)

	local height = n * PlanetData.MountainHeight
	return height * mask
end

local function GetHeight(Normal)
	local base = BaseHeight(Normal)
	local detail = DetailHeight(Normal)

	local terrain = GetTerrainData(Normal)

	local cliff = CliffHeight(Normal, terrain.Continent)
	local mountain = MountainHeight(Normal)

	local height = base + detail + cliff + mountain
	return height
end

--Color Functions
local function GetTriangleColor(Normal)
	local terrain = GetTerrainData(Normal)
	if terrain.IsLand then
		return LandColorId
	else
		return OceanColorId
	end
end

--Others
local function CubeToSphere(v)
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

local function MaxRadius(Radius)
	return PlanetData.BaseHeight + PlanetData.DetailHeight + (Radius * 0.03) + PlanetData.MountainHeight
end

local function ComputeSafeRadius()
	local maxR = PlanetData.Radius

	while true do
		local maxHeight = MaxRadius(maxR)
		local size = (maxR + maxHeight) * 2

		if size <= MAX_MESH_SIZE then
			return maxR
		end

		local scale = MAX_MESH_SIZE / size
		maxR *= scale
	end
end

--RADIUS--
PlanetData.Radius = ComputeSafeRadius()
print(PlanetData.Radius)
UpdateResolution()

--RADIUS DEPENDENT VARS--
PlanetData.BaseHeight = PlanetData.Radius * 0.04
PlanetData.DetailHeight = PlanetData.Radius * 0.025
PlanetData.MountainHeight = PlanetData.Radius * 0.2

PlanetData.DetailScale = 8 * (PlanetData.Radius / refRadius)
PlanetData.MountainScale = 4 * (PlanetData.Radius / refRadius)

--SETUP--
local Existing = workspace:FindFirstChild("Planet")

if Existing then
	Existing:Destroy()
end

local Planet = Instance.new("Folder")
Planet.Name = "Planet" --TODO get name from seed
Planet.Parent = workspace

--MAIN GENERATION LOOP--
for _, Face in ipairs(Faces) do
	local FaceFolder = Instance.new("Folder")
	FaceFolder.Name = Face.Name
	FaceFolder.Parent = Planet

	local Mesh = AssetService:CreateEditableMesh()

	local Vertices = {}
	local Colors = {}

	--VERTEX LOOPS--
	for y = 0, FaceResolution do
		Vertices[y] = {}
		for x = 0, FaceResolution do
			local alphaX = x / FaceResolution
			local alphaY = y / FaceResolution

			local u = alphaX * 2 - 1
			local v = alphaY * 2 - 1

			local CubePoint = Face.Normal + Face.Right * u + Face.Up * v

			local Normal = CubeToSphere(CubePoint)

			local Height = GetHeight(Normal)

			local SpherePoint =
				--PlanetPosition +
				Normal * (PlanetData.Radius + Height)

			if SpherePoint.Magnitude ~= SpherePoint.Magnitude then
				error("NAN vertex")
			end
			if SpherePoint.Magnitude > 5000 then
				error("Impossible Vertex: " .. tostring(SpherePoint))
			end

			local vertex = Mesh:AddVertex(SpherePoint)
			Vertices[y][x] = vertex

			Colors[y] = Colors[y] or {}
			Colors[y][x] = Mesh:AddColor(GetTriangleColor(Normal), 1)
		end
	end

	--TRIANGLE LOOP--
	for y = 0, FaceResolution - 1 do
		for x = 0, FaceResolution - 1 do
			local a = Vertices[y][x]
			local b = Vertices[y][x + 1]
			local c = Vertices[y + 1][x]
			local d = Vertices[y + 1][x + 1]

			local face1 = Mesh:AddTriangle(a, b, c)
			local face2 = Mesh:AddTriangle(b, d, c)

			Mesh:SetVertexFaceColor(a, face1, Colors[y][x])
			Mesh:SetVertexFaceColor(b, face1, Colors[y][x + 1])
			Mesh:SetVertexFaceColor(c, face1, Colors[y + 1][x])

			Mesh:SetVertexFaceColor(b, face2, Colors[y][x + 1])
			Mesh:SetVertexFaceColor(d, face2, Colors[y + 1][x + 1])
			Mesh:SetVertexFaceColor(c, face2, Colors[y + 1][x])
		end
	end

	--CREATION--
	local Success, Result = pcall(function()
		return AssetService:CreateMeshPartAsync(Content.fromObject(Mesh), {
			CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
		})
	end)
	print("Mesh creation Success")

	if not Success then
		error(Result)
	end

	local MeshPart = Result

	MeshPart.Name = Face.Name

	MeshPart.Anchored = true
	MeshPart.Parent = FaceFolder
end
print("Planet generation complete")
