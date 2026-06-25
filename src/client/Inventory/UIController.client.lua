local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local uis = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local gui = player:WaitForChild("PlayerGui")
local playerInventory = gui:WaitForChild("Inventory")
local inventoryGui = gui:WaitForChild("Inventory")
local itemInfo = inventoryGui.positioning:WaitForChild("ItemInfo")
local hotbar = gui:WaitForChild("Hotbar")

local starterGui = game:GetService("StarterGui")
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local Inventory = require(script.Parent:WaitForChild("Inventory"))
local DragController = require(script.Parent:WaitForChild("DragController"))
local Items = require(game.ReplicatedStorage:WaitForChild("ItemDatabase"))

local HOTBAR_SIZE = 9
local SlotRegistry = {}

local activeContainer = nil
local ContainerStart = nil
local ContainerEnd = nil

local selectedSlot = nil
local slotImages = {
	Default = "rbxassetid://89175117594739",
	Hover = "rbxassetid://72163720101959",
	Selected = "rbxassetid://92345702814524"
}

DragController:Init(Inventory, SlotRegistry)

local function getIcon(itemId)
	local itemDatabase = require(game.ReplicatedStorage:WaitForChild("ItemDatabase"))
	return itemDatabase[itemId].Icon
end

local function getSlotUI(index)
	if index <= HOTBAR_SIZE then
		return hotbar.Frame:FindFirstChild("Slot" .. index)
	end
	
	local startIndex = ContainerStart or 10
	local endIndex = ContainerEnd or 30
	
	for i = startIndex, endIndex do
		local slotUI = inventoryGui.positioning.MainBackground.Slots:FindFirstChild("Slot" .. i)
		
		if slotUI and slotUI:GetAttribute("SlotIndex") == index then
			return slotUI
		end
	end
end

local function updateSlotImage(slotUI, isHovering)
	if not slotUI then return end
	for i = 1, 9 do
		if slotUI:GetAttribute("SlotIndex") == i then return end
	end
	local selected = slotUI:GetAttribute("Selected")
	local scale = slotUI:FindFirstChild("UIScale")

	if selected then
		slotUI.Image = slotImages.Selected
		scale.Scale = 1.3
	elseif isHovering then
		slotUI.Image = slotImages.Hover
		scale.Scale = 1
	else
		slotUI.Image = slotImages.Default
		scale.Scale = 1
	end
end

local function addSpaces(str)
	return str:gsub("(%l)(%u)", function(a, b)
		return a .. " " .. b
	end)
end

local function clearItemInfo()
	itemInfo["1"].Visible = false
	itemInfo["2"].Visible = false
	itemInfo["3"].Visible = false
	itemInfo.ItemImage.Image = ""
end
local function renderItemInfo(slotUI)
	for i = 1, 9 do
		if slotUI:GetAttribute("SlotIndex") == i then return end
	end
	
	local index = slotUI:GetAttribute("SlotIndex")
	if not index then return end
	
	if Inventory.Slots[index] == nil then return end
	
	local id = Inventory.Slots[index].ItemId
	if not id then return end
	
	local slotData = Items[id]
	if not slotData then return end
	
	clearItemInfo()
	
	itemInfo.ItemImage.Image = getIcon(slotData.ItemId)
	
	if slotData.Damage and slotData.Durability then
		local frame = itemInfo["1"]
		frame.Visible = true
		frame.Durability.Text.Text = "Durability: 0000/" .. tostring(slotData.Durability) --TODO add actual durability
		frame.Power.Text.Text = "Power: " .. tostring(slotData.Damage)
		frame.Description.Text = slotData.Description
		frame.ItemName.Text = addSpaces(slotData.ItemId)
		frame.Location.Text = "Found on: " --TODO resource locations
	elseif slotData.Durability then
		local frame = itemInfo["2"]
		frame.Visible = true
		frame.Durability.Text.Text = "Durability: 0000/" .. tostring(slotData.Durability)
		frame.Description.Text = slotData.Description
		frame.ItemName.Text = addSpaces(slotData.ItemId)
		frame.Location.Text = "Found on: "
	else
		local frame = itemInfo["3"]
		frame.Visible = true
		frame.Description.Text = slotData.Description
		frame.ItemName.Text = addSpaces(slotData.ItemId)
		frame.Location.Text = "Found on: "
	end
end

local function updateSlotScale(slotUI)
	local scale = slotUI:FindFirstChild("UIScale")
	local selected = slotUI:GetAttribute("Selected")

	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = slotUI
	end

	if selected then
		scale.Scale = 1.3
	else
		scale.Scale = 1
	end
end

local function selectSlot(slotUI)
	local slotIndex = slotUI:GetAttribute("SlotIndex")
	local slotData = Inventory.Slots[slotIndex]

	if not slotData then
		if selectedSlot then
			selectedSlot:SetAttribute("Selected", false)
			updateSlotImage(selectedSlot, false)
			selectedSlot = nil
		end

		clearItemInfo()
		return
	end

	if selectedSlot == slotUI then
		slotUI:SetAttribute("Selected", false)
		updateSlotImage(slotUI, true)

		clearItemInfo()
		updateSlotImage()
		selectedSlot = nil

		return
	end

	if selectedSlot then
		selectedSlot:SetAttribute("Selected", false)
		updateSlotImage(selectedSlot, false)
	end

	slotUI:SetAttribute("Selected", true)
	updateSlotImage(slotUI, true)

	selectedSlot = slotUI
	renderItemInfo(slotUI)
end

local function isShiftHeld()
	return uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)
end
local function quickMove(slotIndex, indexStart, indexEnd)
	if not slotIndex then return end
	
	local destination
	if slotIndex > 9 then
		destination = "inventory"
	else
		destination = "hotbar"
	end

	local fromSlot = Inventory:GetSlot(slotIndex)
	if not fromSlot then return end
	
	local start
	local final
	if indexStart then
		start = indexStart
		final = indexEnd
	end
	if destination == "hotbar" and not start and not final then
		start = 10
		final = 30
	elseif destination == "inventory" and not start and not final then
		start = 1
		final = 9
	end
	print("moving ", fromSlot.ItemId, "from ", start, " to ", final)
	local toSlotIndex = Inventory:NextTransferableIndex(fromSlot.ItemId, start, final)
	if not toSlotIndex then return end
	
	Inventory:MoveSlot(slotIndex, toSlotIndex)
	if selectedSlot == fromSlot then
		selectedSlot = nil
		clearItemInfo()
	end
end

local function render()
	for i = ContainerStart or 1, ContainerEnd or Inventory.TotalSlots do
		local slotData = Inventory.Slots[i]
		local slotUI = getSlotUI(i)

		if slotUI then
			local icon = slotUI:FindFirstChild("ItemImage")
			local amount = slotUI:FindFirstChild("ItemAmount")

			if slotData then
				icon.Image = getIcon(slotData.ItemId)
				icon.Visible = true

				if slotData.Amount > 1 then
					amount.Text = tostring(slotData.Amount)
					amount.Visible = true
				else
					amount.Visible = false
				end
			else
				icon.Image = ""
				icon.Visible = false
				if amount then amount.Visible = false end
			end
		end
	end
end

Inventory.Changed.Event:Connect(function()
	render()
	local percent = Inventory:GetCapacityPercent()
	inventoryGui.positioning.MainBackground.Capacity.Text = percent .. "%"
end)
render()
inventoryGui.positioning.MainBackground.Capacity.Text = Inventory:GetCapacityPercent() .. "%"

local function connectSlot(slotUI, index)
	SlotRegistry[slotUI] = index
	slotUI:SetAttribute("SlotIndex", index)
	slotUI:SetAttribute("Selected", false)

	slotUI.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
			return
		end
		
		if isShiftHeld() then
			quickMove(slotUI:GetAttribute("SlotIndex"), ContainerStart, ContainerEnd)
			return
		end
		
		if input.UserInputType ~= Enum.UserInputType.MouseButton2 then
			selectSlot(slotUI)
		end
		
		DragController:StartDrag(slotUI, uis:GetMouseLocation(), input.UserInputType)
	end)
	
	slotUI.MouseEnter:Connect(function()
		updateSlotImage(slotUI, true)
	end)
	slotUI.MouseLeave:Connect(function()
		updateSlotImage(slotUI, false)
	end)
	updateSlotImage(slotUI, false)
end

local SLOT_INDEX = 1
for i = SLOT_INDEX, HOTBAR_SIZE do
	local slotUI = hotbar.Frame:FindFirstChild("Slot" .. SLOT_INDEX)
	if slotUI then
		connectSlot(slotUI, SLOT_INDEX)
	end
	slotUI:SetAttribute("SlotIndex", SLOT_INDEX)
	SLOT_INDEX += 1
end

for i = SLOT_INDEX, Inventory.TotalSlots do
	local slotUI = inventoryGui.positioning.MainBackground.Slots:FindFirstChild("Slot" .. SLOT_INDEX)

	if slotUI then
		connectSlot(slotUI, SLOT_INDEX)
	end
	slotUI:SetAttribute("SlotIndex", SLOT_INDEX)
	SLOT_INDEX += 1
end

for _, chest in ipairs(workspace.Chests:GetChildren()) do
	for i, slot in ipairs(chest.GUI:WaitForChild("Inventory").SurfaceGui.positioning.MainBackground:WaitForChild("Slots"):GetChildren()) do
		if slot:IsA("ImageButton") then
			connectSlot(slot, SLOT_INDEX)
		end
		slot:SetAttribute("SlotIndex", SLOT_INDEX)
		SLOT_INDEX += 1
	end
end

uis.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	DragController:UpdateDrag(uis:GetMouseLocation())
end)

uis.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end

	local cancelled = DragController:EndDrag(uis:GetMouseLocation()).cancelled
	if selectedSlot and not cancelled then
		selectedSlot:SetAttribute("Selected", false)
		updateSlotImage(selectedSlot, false)
		clearItemInfo()
		selectedSlot = nil
	end
end)

uis.InputBegan:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.E and not activeContainer then
		inventoryGui.Enabled = not inventoryGui.Enabled
	end
end)

--chests
local function setCharacterVisible(visible)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = visible and 0 or 1
		end
	end
end

local events = rs.Events
local OpenContainer = events.OpenContainer
local CloseContainer = events.CloseContainer

OpenContainer.OnClientEvent:Connect(function(container)
	ContainerStart = container.GUI.Inventory.SurfaceGui.positioning.MainBackground.Slots.Slot1:GetAttribute("SlotIndex")
	ContainerEnd = container.GUI.Inventory.SurfaceGui.positioning.MainBackground.Slots.Slot21:GetAttribute("SlotIndex")
	
	playerInventory.Enabled = false
	DragController:SetContainerOpen(true)
	activeContainer = container
	
	setCharacterVisible(false)
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = container.Camera.Value
	
	local chestGui = container.GUI.Chest.SurfaceGui
	inventoryGui = container.GUI.Inventory.SurfaceGui
	itemInfo = container.GUI.ItemInfo.SurfaceGui.ItemInfo
	
	chestGui.Enabled = true
	inventoryGui.Enabled = true
	itemInfo.Parent.Enabled = true
	render()
end)

CloseContainer.OnClientEvent:Connect(function(container)
	ContainerStart = nil
	ContainerEnd = nil
	
	DragController:SetContainerOpen(false)
	activeContainer = nil
	
	setCharacterVisible(true)
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	
	local chestGui = container.GUI.Chest.SurfaceGui
	inventoryGui = container.GUI.Inventory.SurfaceGui
	itemInfo = container.GUI.ItemInfo.SurfaceGui.ItemInfo

	chestGui.Enabled = false
	inventoryGui.Enabled = false
	itemInfo.Parent.Enabled = false
	
	inventoryGui = gui:WaitForChild("Inventory")
	itemInfo = inventoryGui.positioning:WaitForChild("ItemInfo")
	render()
end)