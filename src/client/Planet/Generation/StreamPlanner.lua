local StreamPlanner = {}

StreamPlanner.HiddenCorner = {
	NW = 1,
	NE = 2,
	SW = 3,
	SE = 4,
}
local CornerOffsets = {
	[StreamPlanner.HiddenCorner.NW] = Vector2.new(-1, 1),
	[StreamPlanner.HiddenCorner.NE] = Vector2.new(1, 1),
	[StreamPlanner.HiddenCorner.SW] = Vector2.new(-1, -1),
	[StreamPlanner.HiddenCorner.SE] = Vector2.new(1, -1),
}

function StreamPlanner.GetPlan(Face, CenterChunkX, CenterChunkY, HiddenCorner)
	local Plan = {}
	local Hidden = CornerOffsets[HiddenCorner]

	for OffsetY = -1, 1 do
		for OffsetX = -1, 1 do
			if OffsetX == Hidden.X and OffsetY == Hidden.Y then
				continue
			end

			table.insert(Plan, {
				Face = Face,
				ChunkX = CenterChunkX + OffsetX,
				ChunkY = CenterChunkY + OffsetY,
			})
		end
	end

	return Plan
end

return StreamPlanner
