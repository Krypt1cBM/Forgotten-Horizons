local StreamPlanner = {}

StreamPlanner.HiddenCorner = {
	NW = 1,
	NE = 2,
	SW = 3,
	SE = 4,
}

local cornerOffsets = {
	[StreamPlanner.HiddenCorner.NW] = Vector2.new(-1, 1),
	[StreamPlanner.HiddenCorner.NE] = Vector2.new(1, 1),
	[StreamPlanner.HiddenCorner.SW] = Vector2.new(-1, -1),
	[StreamPlanner.HiddenCorner.SE] = Vector2.new(1, -1),
}

function StreamPlanner.getPlan(location, hiddenCorner)
	local plan = {}
	local hidden = cornerOffsets[hiddenCorner]

	for offsetY = -1, 1 do
		for offsetX = -1, 1 do
			if offsetX == hidden.X and offsetY == hidden.Y then
				continue
			end

			table.insert(plan, {
				face = location.face,
				chunkX = location.chunkX + offsetX,
				chunkY = location.chunkY + offsetY,
			})
		end
	end

	return plan
end

return StreamPlanner
