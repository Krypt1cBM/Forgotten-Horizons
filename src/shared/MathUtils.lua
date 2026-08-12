local MathUtils = {}

function MathUtils.smoothStep(t)
	return t * t * (3 - 2 * t)
end

function MathUtils.lerp(a, b, t)
	return a + (b - a) * t
end

function MathUtils.inverseLerp(Current, Min, Max)
	return (Current - Min) / (Max - Min)
end

function MathUtils.projectOntoPlane(vector, normal)
	return vector - normal * vector:Dot(normal)
end

return MathUtils
