local Inventory = {
	Slots = {
		[1] = nil,
		[2] = nil,
		[3] = nil,
		[4] = nil,
		[5] = nil,
		[6] = nil,
		[7] = nil,
		[8] = nil,
		[9] = nil,
		[10] = nil,
		[11] = nil,
		[12] = nil,
		[13] = nil,
		[14] = nil,
		[15] = nil,
		[16] = nil,
		[17] = nil,
		[18] = nil,
		[19] = nil,
		[20] = nil,
		[21] = nil,
		[22] = nil,
		[23] = nil,
		[24] = nil,
		[25] = nil,
		[26] = nil,
		[27] = nil,
		[28] = nil,
		[29] = nil,
		[30] = nil
	}
}

local Items = require(game.ReplicatedStorage:WaitForChild("ItemDatabase"))
Inventory.TotalSlots = 30

Inventory.Changed = Instance.new("BindableEvent")
function Inventory:FireChanged()
	self.Changed:Fire()
end

function Inventory:GetSlot(i)
	return self.Slots[i]
end
function Inventory:GetIndex(itemData, start, final)
	for i = start or 1, final or Inventory.TotalSlots do
		if self.Slots[i] == itemData then
			return i
		end
	end
	return nil
end

function Inventory:SetSlot(slot, item)
	if not self.Slots[slot] then
		self.Slots[slot] = item
		Inventory:FireChanged()
		return true
	end
	
	self.Slots[slot] = item
	Inventory:FireChanged()
	return true
end

function Inventory:NextTransferableIndex(itemId, start, final)
	for i = start or 1, final or Inventory.TotalSlots do
		local slot = self.Slots[i]
		
		if slot and slot.ItemId == itemId
			and Items[slot.ItemId].MaxStack > slot.Amount then
				return i
		end
	end
	for i = start or 1, final or Inventory.TotalSlots do
		if self.Slots[i] == nil then
			return i
		end
	end
	return nil
end

function Inventory:AddItem(itemId, amount)
	local max = Items[itemId].MaxStack
	local remaining = amount
	
	for i = 1, Inventory.TotalSlots do
		if self.Slots[i] and self.Slots[i].ItemId == itemId and self.Slots[i].Amount < max then
			local space = max - self.Slots[i].Amount
			local toAdd = math.min(space, remaining)
			
			self.Slots[i].Amount += toAdd
			remaining -= toAdd
			
			if remaining <= 0 then
				Inventory:FireChanged()
				return 0
			end
		end
	end
	
	for i = 1, Inventory.TotalSlots do
		if self.Slots[i] == nil then
			local toPlace = math.min(max, remaining)
			
			self.Slots[i] = {
				ItemId = itemId,
				Amount = toPlace
			}
			
			remaining -= toPlace
			
			if remaining <= 0 then
				Inventory:FireChanged()
				return 0
			end
		end
	end
	Inventory:FireChanged()
	return remaining
end

function Inventory:RemoveItem(itemId, amount)
	local remaining = amount
	
	for i = 1, Inventory.TotalSlots do
		if self.Slots[i] and self.Slots[i].ItemId == itemId then
			local toRemove = math.min(self.Slots[i].Amount, remaining)
			self.Slots[i].Amount -= toRemove
			remaining -= toRemove
			
			if self.Slots[i].Amount <= 0 then
				self.Slots[i] = nil
			end
			
			if remaining <= 0 then
				return true
			end
		end
	end
	Inventory:FireChanged()
	return false
end

function Inventory:CountItem(itemId)
	local total = 0
	for i = 1, Inventory.TotalSlots do
		if self.Slots[i] and self.Slots[i].ItemId == itemId then
			total += self.Slots[i].Amount
		end
	end
	return total
end

function Inventory:HasItem(itemId, amount)
	return self:CountItem(itemId) >= (amount or 1)
end

function Inventory:MoveSlot(from, to)
	if not from or not to then return end
	if from == to then return end
	if from < 1 or from > self.TotalSlots then return end
	if to < 1 or to > self.TotalSlots then return end
	
	local a = self.Slots[from]
	local b = self.Slots[to]

	if not a then return end

	if b and (typeof(a.Amount) ~= "number" or typeof(b.Amount) ~= "number") then
		return
	end
	
	if not b then
		self.Slots[to] = a
		self.Slots[from] = nil
		self:FireChanged()
		return
	end
	
	local aData = Items[a.ItemId]
	local bData = Items[b.ItemId]
	
	if a.ItemId == b.ItemId and aData.MaxStack ~= 1 then
		local max = aData.MaxStack
		local space = max - b.Amount
		if space <= 0 then return end
		
		local transfer = math.min(space, a.Amount)
		
		b.Amount += transfer
		a.Amount -= transfer
		
		if a.Amount <= 0 then
			self.Slots[from] = nil
		end
		
		self:FireChanged()
		return
	end
	
	self.Slots[from], self.Slots[to] = b, a
	self:FireChanged()
end

function Inventory:IsFull()
	local max = 16

	for i = 1, self.TotalSlots do
		local slot = self.Slots[i]

		if not slot then
			return false
		end

		if typeof(slot.Amount) ~= "number" then
			warn("Corrupted slot amount at index", i)
			return false
		end

		if slot.Amount < max then
			return false
		end
	end

	return true
end

function Inventory:Clear()
	for i = 1, Inventory.TotalSlots do
		self.Slots[i] = nil
	end

	self.Changed:Fire()
end

function Inventory:LoadStarterItems()
	local Items = require(game.ReplicatedStorage:WaitForChild("ItemDatabase"))
	local starterPack = game:GetService("StarterPack")
	
	for _, tool in ipairs(starterPack:GetChildren()) do
		if tool:IsA("Tool") then
			local itemData = Items[tool.Name]
			
			if itemData then
				self:AddItem(tool.Name, 1)
			end
		end
	end
end

function Inventory:SplitStack(slotIndex, amount)
	if not slotIndex then return nil end

	local slot = self.Slots[slotIndex]
	if not slot then return nil end

	if slot.Amount <= 1 then return nil end
	if amount >= slot.Amount then return nil end

	return {
		ItemId = slot.ItemId,
		Amount = amount
	}
end

function Inventory:RevertSplit(slotIndex, splitStack)
	assert(slotIndex, "RevertSplit: slotIndex is nil")
	assert(splitStack, "RevertSplit: splitStack is nil")
	
	local slot = self.Slots[slotIndex]

	if not slot then
		self.Slots[slotIndex] = {
			ItemId = splitStack.ItemId,
			Amount = splitStack.Amount
		}
	else
		slot.Amount = (slot.Amount or 0) + splitStack.Amount 
	end
end

function Inventory:GetCapacityPercent()
	local usedCapacity = 0
	local totalCapacity = self.TotalSlots

	for i = 1, self.TotalSlots do
		local slot = self.Slots[i]

		if slot then
			local itemData = Items[slot.ItemId]

			if itemData and itemData.MaxStack and itemData.MaxStack > 0 then
				usedCapacity += slot.Amount / itemData.MaxStack
			end
		end
	end

	return math.floor((usedCapacity / totalCapacity) * 100 + 0.5)
end

Inventory:LoadStarterItems()
return Inventory