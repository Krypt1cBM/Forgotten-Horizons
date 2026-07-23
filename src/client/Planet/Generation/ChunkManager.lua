local Constants = require(script.Parent.Parent.Constants)

local Chunk = require(script.Parent.Chunk)
local StreamPlanner = require(script.Parent.StreamPlanner)

local ChunkManager = {}

local physicalChunks = {}

local faceChunkCount = nil
local chunkSize = nil

local currentFace = nil
local currentChunkX = nil
local currentChunkY = nil

local planetContext

function ChunkManager.initialize()
	local PlanetContext = require(script.Parent.PlanetContext)

	planetContext = PlanetContext.new({
		radius = Constants.Planet.RADIUS,
		resolution = Constants.Planet.RESOLUTION,
		center = Constants.Planet.CENTER,
		maxHeight = 0,
	})

	local currentLocation = {
		face = "+Y",
		chunkX = math.floor(planetContext.faceChunkCount / 2),
		chunkY = math.floor(planetContext.faceChunkCount / 2),
	}

	local currentHiddenCorner = StreamPlanner.HiddenCorner.SE

	local plan = StreamPlanner.getPlan(currentLocation, currentHiddenCorner)

	for _, location in ipairs(plan) do
		local chunk = Chunk.new()

		chunk:generate(planetContext, location)

		table.insert(physicalChunks, chunk)
	end
end

function ChunkManager.update()
	--local plan = StreamPlanner.getPlan()
	--TODO compare loaded chunks
end

return ChunkManager
