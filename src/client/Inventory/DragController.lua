local DragController = {}

local player = game.Players.LocalPlayer

DragController.isDragging = false
DragController.fromSlot = nil
DragController.ghost = nil
DragController.dragOffset = Vector2.new(0, 0)
DragController.Inventory = nil
DragController.splitStack = nil
DragController.wasSplit = false
DragController.splitAmount = 0
DragController.dragMode = "Full"

function DragController:Init(inventory, slotRegistry)
	self.Inventory = inventory
	self.SlotRegistry = slotRegistry
end

function DragController:StartDrag(slotUI, inputPosition, inputType)
	if self.isDragging then return end

	local slotIndex = slotUI:GetAttribute("SlotIndex")
	if not slotIndex then return end

	local item = self.Inventory:GetSlot(slotIndex)
	if not item then return end

	self.fromSlot = slotIndex
	self.dragMode = "Full"
	self.splitStack = nil
	self.wasSplit = false
	self.splitAmount = 0

	if inputType == Enum.UserInputType.MouseButton2 then
		self.dragMode = "Split"

		local amount = item.Amount
		local take

		if amount == 1 then
			take = 1
		elseif amount % 2 == 0 then
			take = amount / 2
		else
			take = math.ceil(amount / 2)
		end

		self.splitAmount = take

		if amount ~= 1 then
			self.splitStack = self.Inventory:SplitStack(slotIndex, take)
			if self.splitStack then
				self.wasSplit = true
			end
		else
			self.dragMode = "Full"
		end
	end

	self.isDragging = true

	local mouse = player:GetMouse()
	self.dragOffset = Vector2.new(
		mouse.X - slotUI.AbsolutePosition.X,
		mouse.Y - slotUI.AbsolutePosition.Y
	)

	local icon = slotUI:FindFirstChild("ItemImage")
	if not icon then
		self.isDragging = false
		self.fromSlot = nil
		return
	end

	local ghost = icon:Clone()
	if not ghost then
		self.isDragging = false
		self.fromSlot = nil
		return
	end

	ghost.Visible = true
	ghost.Parent = player.PlayerGui.Inventory
	ghost.ZIndex = 10
	ghost.Interactable = false
	ghost.Size = UDim2.fromOffset(slotUI.AbsoluteSize.X, slotUI.AbsoluteSize.Y)
	ghost.AnchorPoint = Vector2.new(0.5, 1)
	ghost.Position = UDim2.fromOffset(inputPosition.X, inputPosition.Y)

	self.ghost = ghost
end

function DragController:UpdateDrag(inputPosition)
	if not self.isDragging or not self.ghost then return end
	self.ghost.Position = UDim2.fromOffset(inputPosition.X, inputPosition.Y)
end

function DragController:EndDrag(mousePosition)
	if not self.isDragging or not self.fromSlot then
		self:Cleanup()
		return {
			cancelled = true
		}
	end

	local guiInset = game:GetService("GuiService"):GetGuiInset()
	mousePosition = mousePosition - guiInset

	local targetSlotIndex = nil

	for slotUI, index in pairs(self.SlotRegistry) do
		if self.ContainerOpen and index >= 10 and index <= 30 then
			continue
		end
		
		local pos = slotUI.AbsolutePosition
		local size = slotUI.AbsoluteSize

		if mousePosition.X >= pos.X
			and mousePosition.X <= pos.X + size.X
			and mousePosition.Y >= pos.Y
			and mousePosition.Y <= pos.Y + size.Y then

			targetSlotIndex = index
			break
		end
	end

	if not targetSlotIndex then
		if self.wasSplit and self.splitStack then
			self.Inventory:RevertSplit(self.fromSlot, self.splitStack)
		end

		self:Cleanup()
		return {
			cancelled = true
		}
	end

	if targetSlotIndex == self.fromSlot then
		if self.wasSplit and self.splitStack then
			self.Inventory:RevertSplit(self.fromSlot, self.splitStack)
		end

		self:Cleanup()
		return {
			cancelled = true
		}
	end

	local targetSlot = self.Inventory:GetSlot(targetSlotIndex)

	if self.dragMode == "Split" and self.splitStack then
		if not targetSlot then
			self.Inventory.Slots[targetSlotIndex] = self.splitStack

			local source = self.Inventory:GetSlot(self.fromSlot)
			if source then
				source.Amount -= self.splitStack.Amount
				if source.Amount <= 0 then
					self.Inventory.Slots[self.fromSlot] = nil
				end
			end

			self.Inventory:FireChanged()
			
		elseif targetSlot.ItemId == self.splitStack.ItemId then
			targetSlot.Amount += self.splitStack.Amount

			local source = self.Inventory:GetSlot(self.fromSlot)
			if source then
				source.Amount -= self.splitStack.Amount
				if source.Amount <= 0 then
					self.Inventory.Slots[self.fromSlot] = nil
				end
			end

			self.Inventory:FireChanged()
		else
			if self.wasSplit and self.splitStack then
				self.Inventory:RevertSplit(self.fromSlot, self.splitStack)
			end

			self:Cleanup()
			return
		end

	else
		self.Inventory:MoveSlot(self.fromSlot, targetSlotIndex)
	end

	self:Cleanup()

	return {
		fromSlot = self.fromSlot,
		droppedToSlot = targetSlotIndex,
		cancelled = false,
		didMove = true
	}
end

function DragController:SetContainerOpen(open)
	self.ContainerOpen = open
end

function DragController:Cleanup()
	self.isDragging = false
	self.fromSlot = nil
	self.dragOffset = Vector2.new(0, 0)
	self.dragMode = "Full"
	self.splitStack = nil
	self.wasSplit = false
	self.splitAmount = 0

	if self.ghost then
		self.ghost:Destroy()
		self.ghost = nil
	end
end

return DragController