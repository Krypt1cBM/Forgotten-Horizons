local Items = {}

--RESOURCES--
Items.Stone = {
	ItemId = "Stone",
	Category = "Resources",
	MaxStack = 16,
	Icon = "rbxassetid://100156708852235",
	Description = "Stone used for tools, or as a projectile."
}
Items.Twig = {
	ItemId = "Twig",
	Category = "Resources",
	MaxStack = 16,
	Icon = "rbxassetid://106542249013491",
	Description = "Twig mainly used for handles, or wapping your incompetent teammate."
}

--WEAPONS--
Items.StoneSword = {
	ItemId = "StoneSword",
	Category = "Weapons",
	MaxStack = 1,
	Icon = "",
	Damage = 3,
	Durability = 170,
	Cooldown = 1,
	Range = 3,
	Description = "Sword made of stone. Not very efficient to wield."
}

--TOOLS--
Items.StonePickaxe = {
	ItemId = "StonePickaxe",
	Category = "Tools",
	MaxStack = 1,
	Icon = "rbxassetid://127451108653756",
	Damage = 2,
	Durability = 200,
	Cooldown = 1.5,
	Tier = 1,
	Description = "Simple stone pickaxe. Everyone starts somewhere."
}
Items.StoneAxe = {
	ItemId = "StoneAxe",
	Category = "Tools",
	MaxStack = 1,
	Icon = "rbxassetid://119174143605035",
	Damage = 3,
	Durability = 200,
	Cooldown = 1.5,
	Tier = 1,
	Description = "A tree's not so great enemy."
}

return Items