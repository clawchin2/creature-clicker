-- HatchSystem.lua
-- Handles egg hatching logic and creature generation

local HatchSystem = {}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load PlayerData module
local PlayerData = require(script.Parent.PlayerData)

-- Hatch configuration
HatchSystem.HATCH_DURATION = 3 -- seconds for hatch animation

-- Creature visual presets (would link to actual models in production)
HatchSystem.CreatureModels = {
	Common = "rbxassetid://0000001",
	Uncommon = "rbxassetid://0000002",
	Rare = "rbxassetid://0000003",
	Legendary = "rbxassetid://0000004",
	Mythic = "rbxassetid://0000005",
}

function HatchSystem:RollRarity(eggType)
	local rarities = PlayerData.CreatureRarities[eggType]
	if not rarities then
		return "Common", {1.0, 1.5}
	end
	
	local roll = math.random(1, 100)
	local cumulative = 0
	
	for _, rarityData in ipairs(rarities) do
		cumulative += rarityData.chance
		if roll <= cumulative then
			return rarityData.rarity, rarityData.multiplierRange
		end
	end
	
	-- Fallback to last rarity
	local last = rarities[#rarities]
	return last.rarity, last.multiplierRange
end

function HatchSystem:GenerateCreatureName(rarity)
	local names = PlayerData.CreatureNames[rarity]
	if names and #names > 0 then
		return names[math.random(1, #names)]
	end
	return "Unknown"
end

function HatchSystem:GenerateMultiplier(multiplierRange)
	local minVal = multiplierRange[1]
	local maxVal = multiplierRange[2]
	return minVal + (math.random() * (maxVal - minVal))
end

function HatchSystem:ShouldAutoEquip(playerData, newCreatureMultiplier)
	local equippedId = playerData:GetEquippedCreature()
	if not equippedId then
		return true -- No creature equipped, auto-equip
	end
	
	local equippedCreature = playerData:GetCreature(equippedId)
	if not equippedCreature then
		return true
	end
	
	return newCreatureMultiplier > equippedCreature.multiplier
end

function HatchSystem:HatchEgg(player, eggId)
	local session = PlayerData:GetSession(player)
	if not session then
		return false, "Player session not found"
	end
	
	-- Verify egg exists
	local egg = session:GetEgg(eggId)
	if not egg then
		return false, "Egg not found in inventory"
	end
	
	local eggType = egg.type
	
	-- Remove egg from inventory
	session:RemoveEgg(eggId)
	
	-- Roll for rarity
	local rarity, multiplierRange = self:RollRarity(eggType)
	
	-- Generate creature stats
	local name = self:GenerateCreatureName(rarity)
	local multiplier = self:GenerateMultiplier(multiplierRange)
	multiplier = math.floor(multiplier * 10) / 10 -- Round to 1 decimal
	
	-- Create creature
	local creatureId = session:AddCreature(name, rarity, multiplier, eggType)
	
	-- Auto-equip if better
	local wasEquipped = false
	if self:ShouldAutoEquip(session, multiplier) then
		session:EquipCreature(creatureId)
		wasEquipped = true
	end
	
	-- Return creature data
	local creatureData = session:GetCreature(creatureId)
	
	return true, {
		creatureId = creatureId,
		name = name,
		rarity = rarity,
		multiplier = multiplier,
		eggType = eggType,
		wasEquipped = wasEquipped,
		modelId = self.CreatureModels[rarity],
	}
end

function HatchSystem:BuyEgg(player, eggType)
	local session = PlayerData:GetSession(player)
	if not session then
		return false, "Player session not found"
	end
	
	-- Verify egg type exists
	local eggData = PlayerData.EggTypes[eggType]
	if not eggData then
		return false, "Invalid egg type"
	end
	
	-- Check if player can afford
	if session:GetCoins() < eggData.price then
		return false, "Not enough coins"
	end
	
	-- Deduct coins
	session:RemoveCoins(eggData.price)
	
	-- Add egg to inventory
	local eggId = session:AddEgg(eggType)
	
	return true, {
		eggId = eggId,
		type = eggType,
		name = eggData.name,
		price = eggData.price,
	}
end

function HatchSystem:GetEggShopData()
	local shopData = {}
	for eggType, data in pairs(PlayerData.EggTypes) do
		table.insert(shopData, {
			type = eggType,
			name = data.name,
			price = data.price,
			color = data.color,
		})
	end
	
	-- Sort by price
	table.sort(shopData, function(a, b)
		return a.price < b.price
	end)
	
	return shopData
end

function HatchSystem:GetPlayerInventory(player)
	local session = PlayerData:GetSession(player)
	if not session then
		return nil
	end
	
	local data = session:GetData()
	return {
		coins = data.coins,
		eggs = data.eggs,
		creatures = data.creatures,
		equippedCreature = data.equippedCreature,
		totalCreatures = data.totalCreatures,
		passiveIncome = session:CalculatePassiveIncome(),
		equippedMultiplier = session:GetEquippedMultiplier(),
	}
end

return HatchSystem