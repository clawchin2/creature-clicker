-- Main.server.lua
-- Main server script handling egg shop and hatch remotes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Load modules
local PlayerData = require(script.Parent.PlayerData)
local HatchSystem = require(script.Parent.HatchSystem)

-- Create RemoteEvents and RemoteFunctions
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

-- RemoteFunctions for request/response
local buyEggRemote = Instance.new("RemoteFunction")
buyEggRemote.Name = "BuyEgg"
buyEggRemote.Parent = remotesFolder

local hatchEggRemote = Instance.new("RemoteFunction")
hatchEggRemote.Name = "HatchEgg"
hatchEggRemote.Parent = remotesFolder

local getCreaturesRemote = Instance.new("RemoteFunction")
getCreaturesRemote.Name = "GetCreatures"
getCreaturesRemote.Parent = remotesFolder

local getInventoryRemote = Instance.new("RemoteFunction")
getInventoryRemote.Name = "GetInventory"
getInventoryRemote.Parent = remotesFolder

-- RemoteEvents for server-to-client updates
local coinsUpdated = Instance.new("RemoteEvent")
coinsUpdated.Name = "CoinsUpdated"
coinsUpdated.Parent = remotesFolder

local creatureHatched = Instance.new("RemoteEvent")
creatureHatched.Name = "CreatureHatched"
creatureHatched.Parent = remotesFolder

local creatureEquipped = Instance.new("RemoteEvent")
creatureEquipped.Name = "CreatureEquipped"
creatureEquipped.Parent = remotesFolder

-- Passive income tracking
local passiveIncomeTimer = 0
local PASSIVE_INCOME_INTERVAL = 1 -- Give coins every second

-- Helper function to safely invoke client callbacks
local function notifyClient(player, remote, ...)
	local success, err = pcall(function(...)
		remote:FireClient(player, ...)
	end, ...)
	if not success then
		warn("Failed to notify client: " .. tostring(err))
	end
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
	print("[Main] Player joined: " .. player.Name)
	
	-- Initialize player data session
	local session = PlayerData.new(player)
	
	-- Give starting coins for testing (remove in production)
	session:AddCoins(100)
	
	-- Notify client of initial coins
	notifyClient(player, coinsUpdated, session:GetCoins())
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
	print("[Main] Player left: " .. player.Name)
	
	local session = PlayerData:GetSession(player)
	if session then
		session:Cleanup()
	end
end)

-- BuyEgg RemoteFunction (Simplified)
-- Client calls: BuyEgg:InvokeServer() → returns {success, remainingCoins, creatureName}
buyEggRemote.OnServerInvoke = function(player)
	print("[Main] BuyEgg requested by " .. player.Name)
	
	local session = PlayerData:GetSession(player)
	if not session then
		return { success = false, remainingCoins = 0, creatureName = nil }
	end
	
	-- Check if player has 10+ coins
	local EGG_PRICE = 10
	if session:GetCoins() < EGG_PRICE then
		return { success = false, remainingCoins = session:GetCoins(), creatureName = nil }
	end
	
	-- Deduct coins
	session:RemoveCoins(EGG_PRICE)
	
	-- Simple Creature Generation: 70% Common, 25% Uncommon, 5% Rare
	local roll = math.random(1, 100)
	local rarity, multiplier
	local creatureNames = {
		Common = {"Froggle", "Bunnip", "Sneetle"},
		Uncommon = {"Glowbug", "Chirpet"},
		Rare = {"Drakeling"},
	}
	
	if roll <= 70 then
		rarity = "Common"
		multiplier = 1.0 + (math.random() * 0.5) -- 1.0 - 1.5x
	elseif roll <= 95 then
		rarity = "Uncommon"
		multiplier = 1.5 + (math.random() * 0.5) -- 1.5 - 2.0x
	else
		rarity = "Rare"
		multiplier = 2.0 + (math.random() * 1.0) -- 2.0 - 3.0x
	end
	
	-- Round multiplier to 1 decimal
	multiplier = math.floor(multiplier * 10) / 10
	
	-- Pick random creature name for rarity
	local names = creatureNames[rarity]
	local creatureName = names[math.random(1, #names)]
	
	-- Add creature to player's inventory
	local creatureId = session:AddCreature(creatureName, rarity, multiplier, "Basic")
	
	-- Auto-equip if this is their first/best creature
	local equippedId = session:GetEquippedCreature()
	if not equippedId then
		session:EquipCreature(creatureId)
	else
		local equipped = session:GetCreature(equippedId)
		if equipped and multiplier > equipped.multiplier then
			session:EquipCreature(creatureId)
		end
	end
	
	-- Notify client of coin update
	notifyClient(player, coinsUpdated, session:GetCoins())
	
	print("[Main] " .. player.Name .. " bought egg, got " .. rarity .. " " .. creatureName .. " (x" .. multiplier .. ")")
	
	-- Return data format as requested
	return {
		success = true,
		remainingCoins = session:GetCoins(),
		creatureName = creatureName
	}
end

-- HatchEgg RemoteFunction
-- Client calls: HatchEgg:InvokeServer(eggId) → returns {success, creature/error}
hatchEggRemote.OnServerInvoke = function(player, eggId)
	print("[Main] HatchEgg requested by " .. player.Name .. " for egg " .. tostring(eggId))
	
	-- Validate input
	if type(eggId) ~= "string" then
		return { success = false, error = "Invalid egg ID format" }
	end
	
	-- Simulate hatch animation delay on server (clients can show animation during this)
	-- In a real implementation, you might want to track active hatches
	
	-- Perform hatch
	local success, result = HatchSystem:HatchEgg(player, eggId)
	
	if success then
		local session = PlayerData:GetSession(player)
		
		-- Notify all clients about hatch (for visual effects)
		notifyClient(player, creatureHatched, {
			creature = result,
			playerName = player.Name,
		})
		
		if result.wasEquipped then
			notifyClient(player, creatureEquipped, {
				creatureId = result.creatureId,
				multiplier = result.multiplier,
			})
		end
		
		print("[Main] " .. player.Name .. " hatched " .. result.rarity .. " " .. result.name .. 
			" (x" .. result.multiplier .. ")" .. (result.wasEquipped and " [AUTO-EQUIPPED]" or ""))
		
		return {
			success = true,
			creature = result,
			equipped = result.wasEquipped,
		}
	else
		print("[Main] HatchEgg failed for " .. player.Name .. ": " .. tostring(result))
		return { success = false, error = result }
	end
end

-- GetCreatures RemoteFunction
-- Client calls: GetCreatures:InvokeServer() → returns inventory data
getCreaturesRemote.OnServerInvoke = function(player)
	print("[Main] GetCreatures requested by " .. player.Name)
	
	local inventory = HatchSystem:GetPlayerInventory(player)
	
	if inventory then
		return { success = true, inventory = inventory }
	else
		return { success = false, error = "Player session not found" }
	end
end

-- GetInventory RemoteFunction (alias for GetCreatures with shop data)
getInventoryRemote.OnServerInvoke = function(player)
	print("[Main] GetInventory requested by " .. player.Name)
	
	local inventory = HatchSystem:GetPlayerInventory(player)
	local shopData = HatchSystem:GetEggShopData()
	
	if inventory then
		return {
			success = true,
			inventory = inventory,
			shop = shopData,
		}
	else
		return { success = false, error = "Player session not found" }
	end
end

-- Passive income loop
RunService.Heartbeat:Connect(function(deltaTime)
	passiveIncomeTimer += deltaTime
	
	if passiveIncomeTimer >= PASSIVE_INCOME_INTERVAL then
		passiveIncomeTimer = 0
		
		-- Give passive income to all players
		for _, player in ipairs(Players:GetPlayers()) do
			local session = PlayerData:GetSession(player)
			if session then
				local income = session:CalculatePassiveIncome()
				if income > 0 then
					local newCoins = session:AddCoins(income)
					notifyClient(player, coinsUpdated, newCoins)
				end
			end
		end
	end
end)

-- Click-to-earn handler (for testing coin generation)
local clickEarnRemote = Instance.new("RemoteFunction")
clickEarnRemote.Name = "ClickEarn"
clickEarnRemote.Parent = remotesFolder

clickEarnRemote.OnServerInvoke = function(player)
	local session = PlayerData:GetSession(player)
	if not session then
		return { success = false, error = "Session not found" }
	end
	
	-- Base click value + equipped creature multiplier
	local multiplier = session:GetEquippedMultiplier()
	local earnings = math.floor(1 * multiplier)
	
	local newCoins = session:AddCoins(earnings)
	
	return {
		success = true,
		earned = earnings,
		coins = newCoins,
	}
end

print("[Main] Creature Simulator server initialized")
print("[Main] Remotes created: BuyEgg, HatchEgg, GetCreatures, GetInventory, ClickEarn")
print("[Main] Passive income system active")

-- Expose for other scripts
_G.PlayerData = PlayerData
_G.HatchSystem = HatchSystem