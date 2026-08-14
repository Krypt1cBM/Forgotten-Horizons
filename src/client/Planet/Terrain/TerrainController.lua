local GeographyGenerator = require(script.Parent.GeographyGenerator)
local MaterialGenerator = require(script.Parent.MaterialGenerator)

local TerrainController = {}

function TerrainController.getTerrain(context, direction)
	local landValue = GeographyGenerator.getLandValue(context, direction)
	local color = MaterialGenerator.getColor(landValue)

	return {
		landValue = landValue,
		color = color,
	}
end

return TerrainController
