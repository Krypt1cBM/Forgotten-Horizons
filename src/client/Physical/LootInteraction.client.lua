local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local lootFolder = workspace.Resources.Loot
local ui = player.PlayerGui:WaitForChild("Guide")

local draggedLoot = nil
local lootList = {}

local function getRoot(loot)
	if loot:IsA("Model") then
		return loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart", true)
	end
	return loot
end

local function registerLoot(loot)
	local highlight = loot:FindFirstChild("Highlight")
	local dragDetector = loot:FindFirstChild("DragDetector")

	if not highlight or not dragDetector then return end

	local root = getRoot(loot)
	if not root then return end

	lootList[loot] = {
		root = root,
		highlight = highlight,
		dragDetector = dragDetector,
	}

	highlight.Adornee = loot
	highlight.Enabled = false

	dragDetector.DragStart:Connect(function()
		draggedLoot = loot
	end)

	dragDetector.DragEnd:Connect(function()
		draggedLoot = nil
	end)
end

for _, loot in ipairs(lootFolder:GetChildren()) do
	registerLoot(loot)
end

lootFolder.ChildAdded:Connect(function(child)
	task.wait()
	registerLoot(child)
end)

lootFolder.ChildRemoved:Connect(function(child)
	lootList[child] = nil
	if draggedLoot == child then
		draggedLoot = nil
	end
end)

mouse.Move:Connect(function()
	local active = false

	local target = mouse.Target

	for loot, data in pairs(lootList) do
		local hovered = target == data.root
		local dragged = draggedLoot == loot

		local isActive = hovered or dragged

		data.highlight.Enabled = isActive

		if isActive then
			active = true
		end
	end

	ui.Enabled = active
end)

local function getValidLoot()
	local target = mouse.Target
	if not target then return nil end

	for loot, data in pairs(lootList) do
		if target == data.root then
			return loot
		end
	end

	return nil
end

local function pickUp(loot)
	if not loot or not lootList[loot] then return end

	local Inventory = require(script.Parent.Parent.Inventory.Inventory)
	local data = lootList[loot]

	Inventory:AddItem(
		loot:GetAttribute("ItemId"),
		loot:GetAttribute("Amount")
	)

	lootList[loot] = nil
	loot:Destroy()
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F then
		local loot = getValidLoot()
		if loot then
			pickUp(loot)
		end
	end
end)