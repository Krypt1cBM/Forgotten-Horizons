local rockDead = game.ReplicatedStorage.Events.RockDies
local rocks = workspace.Resources.Rocks
local tumble = game.ReplicatedStorage.sfx["rock break"]

rockDead.Event:Connect(function(recievedRock)
	local rock = rocks:WaitForChild(tostring(recievedRock))
	rock.Hitbox:Destroy()
	tumble:Play()
	
	for _, part in rock.Rocks:GetChildren() do
		part.Transparency = 0
		part.Anchored = false
		part.CanCollide = true
		part.CanTouch = true
		part.CanQuery = true
		part.Parent = workspace.Resources.Loot
		part:SetAttribute("ItemId", "Stone")
		part:SetAttribute("Category", "Resources")
		part:SetAttribute("Amount", 1)
	end
	for _, child in rock:GetChildren() do
		child:Destroy()
		task.wait(0.1)
	end
	rock:Destroy()
end)