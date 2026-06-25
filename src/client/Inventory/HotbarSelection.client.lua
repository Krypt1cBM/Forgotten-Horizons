local player = game.Players.LocalPlayer
local Inventory = require(script.Parent.Parent.Inventory.Inventory)
local Items = require(game.ReplicatedStorage:WaitForChild("ItemDatabase"))

local slots = player.PlayerGui:WaitForChild("Hotbar").Frame
local selectedSlot = 1
local selectedImage = "rbxassetid://130329946453557"
local ogImage = "rbxassetid://132662420386809"
local ogSize = slots.Slot1.Size

local equippedModel = nil
local equippedItemId = nil

local function equipItem(itemId)
	if equippedModel then
		equippedModel:Destroy()
		equippedModel = nil
	end
	
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid:UnequipTools()
	
	if not itemId then
		humanoid:UnequipTools()
		return
	end
	
	local category = Items[itemId].Category
	if category == "Tools" or category == "Weapons" then
		local backpack = player:FindFirstChild("Backpack")
		if not backpack then return end
		
		local tool = backpack:FindFirstChild(itemId)
		
		if not tool then
			local starter = game:GetService("StarterPack")
			tool = starter:FindFirstChild(itemId)
		end
		
		if tool then
			humanoid:EquipTool(tool)
		end
		return
	end
	
	local heldModels = game.ReplicatedStorage:WaitForChild("HeldModels")
	local template = heldModels:FindFirstChild(itemId)
	if not template then return end
	
	local hand = character:FindFirstChild("RightHand")
	if not hand then return end
	
	equippedModel = template:Clone()
	equippedModel.Parent = workspace
	
	if equippedModel:IsA("Model") then
		equippedModel:PivotTo(hand.CFrame)
	else
		equippedModel.CFrame = hand.CFrame
	end
	
	local weld = equippedModel:FindFirstChild("HandWeld")
	weld.Parent = weld.Part0
	weld.Part1 = hand
end

local function updateHotbar()
	for i = 1, 9 do
		local slot = slots:FindFirstChild("Slot" .. i)
		if slot and slot:IsA("ImageButton") then
			local ogSize = slot:GetAttribute("OriginalSize")
			
			if not ogSize then
				slot:SetAttribute("OriginalSize", slot.Size)
				ogSize = slot.Size
			end
			
			if i == selectedSlot then
				slot.Image = selectedImage
				
				slot.Size = UDim2.new(
					ogSize.X.Scale * 1.1,
					ogSize.X.Offset * 1.1, 
					ogSize.Y.Scale * 1.1,
					ogSize.Y.Offset * 1.1
				)
			else
				slot.Image = ogImage
				slot.Size = ogSize
			end
		end
	end
end

local keyToSlot = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9
}

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
	if gp then return end
	
	local slotNum = keyToSlot[input.KeyCode]
	
	if slotNum then
		selectedSlot = slotNum
		updateHotbar()
	
		local item = Inventory:GetSlot(selectedSlot)
		if item then
			equipItem(item.ItemId)
		else
			equipItem(nil)
		end
	end
end)

for _, slot in ipairs(slots:GetChildren()) do
	if slot:IsA("ImageButton") then
		slot.MouseButton1Click:Connect(function()
			selectedSlot = tonumber(slot.Name:match("%d"))
			updateHotbar()
			
			local item = Inventory:GetSlot(selectedSlot)
			if item then
				equipItem(item.ItemId)
			else
				equipItem(nil)
			end
		end)
	end
end

updateHotbar()