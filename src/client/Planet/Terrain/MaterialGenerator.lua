local MaterialGenerator = {}

local LAND_COLOR = Color3.fromRGB(120, 200, 80)
local OCEAN_COLOR = Color3.fromRGB(30, 100, 220)

function MaterialGenerator.getColor(landValue)
	if landValue >= 0 then
		return LAND_COLOR
	end

	return OCEAN_COLOR
end

return MaterialGenerator
