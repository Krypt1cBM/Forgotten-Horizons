local MathUtils = {}

function MathUtils.SmoothStep(t)
	return t * t * (3 - 2 * t)
end

function MathUtils.Lerp(a, b, t)
	return a + (b - a) * t
end

function MathUtils.InverseLerp(Current, Min, Max)
	return (Current - Min) / (Max - Min)
end

function MathUtils.Clamp01() end

return MathUtils
