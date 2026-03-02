-- PlayerData.lua
-- Manages player data including coins and creature inventory

local PlayerData = {}
PlayerData.__index = PlayerData

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load shared config
local Config = require(ReplicatedStorage.Config)

-- Export config values for other modules
PlayerData.EggTypes = Config.EggTypes
PlayerData.CreatureRarities = Config.CreatureRarities
PlayerData.CreatureNames = Config.CreatureNames

-- Active player sessions
local sessions = {}

function PlayerData.new(player)
	local self = setmetatable({}, PlayerData)
	
	self.player = player
	self.data = {
		coins = 0,
		eggs = {}, -- { eggId = { type = "Basic", acquired = timestamp } }
		creatures = {}, -- { creatureId = { name, rarity, multiplier, eggType } }
		equippedCreature = nil, -- creatureId
		totalCreatures = 0,
	}
	
	sessions[player.UserId] = self
	return self
end

function PlayerData:GetSession(player)
	return sessions[player.UserId]
end

function PlayerData:GetData()
	return self.data
end

function PlayerData:GetCoins()
	return self.data.coins
end

function PlayerData:AddCoins(amount)
	self.data.coins += amount
	return self.data.coins
end

function PlayerData:RemoveCoins(amount)
	if self.data.coins >= amount then
		self.data.coins -= amount
		return true
	end
	return false
end

function PlayerData:AddEgg(eggType)
	local eggId = HttpService:GenerateGUID(false)
	self.data.eggs[eggId] = {
		type = eggType,
		acquired = tick(),
	}
	return eggId
end

function PlayerData:GetEggs()
	return self.data.eggs
end

function PlayerData:GetEgg(eggId)
	return self.data.eggs[eggId]
end

function PlayerData:RemoveEgg(eggId)
	if self.data.eggs[eggId] then
		self.data.eggs[eggId] = nil
		return true
	end
	return false
end

function PlayerData:AddCreature(name, rarity, multiplier, eggType)
	local creatureId = HttpService:GenerateGUID(false)
	self.data.creatures[creatureId] = {
		name = name,
		rarity = rarity,
		multiplier = multiplier,
		eggType = eggType,
		acquired = tick(),
	}
	self.data.totalCreatures += 1
	return creatureId
end

function PlayerData:GetCreatures()
	return self.data.creatures
end

function PlayerData:GetCreature(creatureId)
	return self.data.creatures[creatureId]
end

function PlayerData:EquipCreature(creatureId)
	if self.data.creatures[creatureId] then
		self.data.equippedCreature = creatureId
		return true
	end
	return false
end

function PlayerData:GetEquippedCreature()
	return self.data.equippedCreature
end

function PlayerData:GetEquippedMultiplier()
	if self.data.equippedCreature then
		local creature = self.data.creatures[self.data.equippedCreature]
		if creature then
			return creature.multiplier
		end
	end
	return 1.0 -- Default multiplier
end

function PlayerData:CalculatePassiveIncome()
	local totalIncome = 0
	for _, creature in pairs(self.data.creatures) do
		totalIncome += creature.multiplier * 0.1 -- 10% of multiplier per second
	end
	return totalIncome
end

function PlayerData:Cleanup()
	sessions[self.player.UserId] = nil
end

return PlayerData