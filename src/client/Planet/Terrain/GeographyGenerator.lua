local GeographyGenerator = {}

function GeographyGenerator.getLandValue(context, direction)
	local seedX = context.seed * 1.731
	local seedY = context.seed * 2.913
	local seedZ = context.seed * 4.127

	local continentalScale = 5

	local continental = math.noise(
		direction.X * continentalScale + seedX,
		direction.Y * continentalScale + seedY,
		direction.Z * continentalScale + seedZ
	)

	return continental
end

return GeographyGenerator
