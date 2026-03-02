--[[
    Main Server Script
    Initializes all gameplay systems and handles cross-module communication
    Place this in ServerScriptService
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load modules
local modulesFolder = script.Parent:WaitForChild("Modules")

local CreatureConfig = require(modulesFolder.CreatureConfig)
local PlayerData = require(modulesFolder.PlayerData)
local ClickHandler = require(modulesFolder.ClickHandler)
local HatchSystem = require(modulesFolder.HatchSystem)
local PassiveIncome = require(modulesFolder.PassiveIncome)

-- Initialize all systems
print("=== Creature Clicker Server Starting ===")

-- 1. Initialize PlayerData (must be first)
PlayerData.Init()

-- 2. Initialize ClickHandler
ClickHandler.Init(PlayerData, CreatureConfig)

-- 3. Initialize HatchSystem
HatchSystem.Init(PlayerData, CreatureConfig)

-- 4. Initialize PassiveIncome
PassiveIncome.Init(PlayerData, CreatureConfig)

print("=== All Systems Initialized ===")

-- Setup additional RemoteEvents/Functions
local remotesFolder = ReplicatedStorage:FindFirstChild("CreatureClickerRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "CreatureClickerRemotes"
    remotesFolder.Parent = ReplicatedStorage
    print("[Main] Created CreatureClickerRemotes folder")
end

-- GetCreatures remote (for inventory display)
local GetCreatures = remotesFolder:FindFirstChild("GetCreatures")
if not GetCreatures then
    GetCreatures = Instance.new("RemoteFunction")
    GetCreatures.Name = "GetCreatures"
    GetCreatures.Parent = remotesFolder
end

GetCreatures.OnServerInvoke = function(player)
    return HatchSystem.GetPlayerPets(player)
end

-- EquipPet remote
local EquipPet = remotesFolder:FindFirstChild("EquipPet")
if not EquipPet then
    EquipPet = Instance.new("RemoteFunction")
    EquipPet.Name = "EquipPet"
    EquipPet.Parent = remotesFolder
end

EquipPet.OnServerInvoke = function(player, creatureId)
    if typeof(creatureId) ~= "string" then
        return {success = false, error = "Invalid creature ID"}
    end
    
    local success = HatchSystem.HandleEquipRequest(player, creatureId)
    return {
        success = success,
        equipped = success and creatureId or nil
    }
end

-- UnequipPet remote
local UnequipPet = remotesFolder:FindFirstChild("UnequipPet")
if not UnequipPet then
    UnequipPet = Instance.new("RemoteFunction")
    UnequipPet.Name = "UnequipPet"
    UnequipPet.Parent = remotesFolder
end

UnequipPet.OnServerInvoke = function(player)
    local success = HatchSystem.HandleUnequipRequest(player)
    return {success = success}
end

-- GetPassiveIncomePreview remote
local GetPassiveIncomePreview = remotesFolder:FindFirstChild("GetPassiveIncomePreview")
if not GetPassiveIncomePreview then
    GetPassiveIncomePreview = Instance.new("RemoteFunction")
    GetPassiveIncomePreview.Name = "GetPassiveIncomePreview"
    GetPassiveIncomePreview.Parent = remotesFolder
end

GetPassiveIncomePreview.OnServerInvoke = function(player)
    return PassiveIncome.GetIncomePreview(player)
end

-- BuyEgg remote (simplified direct creature purchase)
local BuyEgg = remotesFolder:FindFirstChild("BuyEgg")
if not BuyEgg then
    BuyEgg = Instance.new("RemoteFunction")
    BuyEgg.Name = "BuyEgg"
    BuyEgg.Parent = remotesFolder
end

BuyEgg.OnServerInvoke = function(player)
    local session = PlayerData.GetSession(player.UserId)
    if not session then
        return {success = false, message = "Session not found"}
    end
    
    local EGG_PRICE = 10
    if session:GetCoins() < EGG_PRICE then
        return {success = false, message = "Need 10 coins"}
    end
    
    -- Deduct coins
    session:RemoveCoins(EGG_PRICE)
    
    -- Generate random creature
    local creatures = {"Froggle", "Bunnip", "Sneetle", "Glowbug"}
    local creatureName = creatures[math.random(1, #creatures)]
    
    -- Map creature name to creature ID for inventory (using existing config IDs)
    local creatureIdMap = {
        Froggle = "fire_common_ember_pup",
        Bunnip = "earth_uncommon_moss_boar", 
        Sneetle = "air_common_gust_sprite",
        Glowbug = "void_uncommon_dark_wolf"
    }
    local creatureId = creatureIdMap[creatureName] or "fire_common_ember_pup"
    
    -- Add to inventory (pets table)
    session:AddPet(creatureId)
    
    return {
        success = true,
        remainingCoins = session:GetCoins(),
        creatureName = creatureName
    }
end

-- GetInventory remote (returns player's creatures as simple list)
local GetInventory = remotesFolder:FindFirstChild("GetInventory")
if not GetInventory then
    GetInventory = Instance.new("RemoteFunction")
    GetInventory.Name = "GetInventory"
    GetInventory.Parent = remotesFolder
end

GetInventory.OnServerInvoke = function(player)
    local session = PlayerData.GetSession(player.UserId)
    if not session then
        return {}
    end
    
    -- Return creatures as simple list of names
    local inventory = {}
    local pets = session:GetPets()
    
    -- Map creature IDs back to simple names
    local idToName = {
        fire_common_ember_pup = "Froggle",
        earth_uncommon_moss_boar = "Bunnip",
        air_common_gust_sprite = "Sneetle", 
        void_uncommon_dark_wolf = "Glowbug"
    }
    
    for creatureId, count in pairs(pets) do
        local name = idToName[creatureId] or "Unknown"
        for i = 1, count do
            table.insert(inventory, name)
        end
    end
    
    return inventory
end

-- GetCreatureConfig remote (for UI reference)
local GetCreatureConfig = remotesFolder:FindFirstChild("GetCreatureConfig")
if not GetCreatureConfig then
    GetCreatureConfig = Instance.new("RemoteFunction")
    GetCreatureConfig.Name = "GetCreatureConfig"
    GetCreatureConfig.Parent = remotesFolder
end

GetCreatureConfig.OnServerInvoke = function(player)
    -- Return safe copy of config data
    local config = {}
    
    -- Rarities
    config.Rarities = {}
    for name, data in pairs(CreatureConfig.Rarities) do
        config.Rarities[name] = {
            multiplier = data.multiplier,
            chancePercent = data.chancePercent,
            color = {r = data.color.R, g = data.color.G, b = data.color.B}
        }
    end
    
    -- Creatures (just names and IDs for reference)
    config.Creatures = {}
    for id, creature in pairs(CreatureConfig.Creatures) do
        config.Creatures[id] = {
            name = creature.name,
            element = creature.element,
            rarity = creature.rarity,
            multiplier = creature.multiplier
        }
    end
    
    -- Eggs
    config.Eggs = {}
    for id, egg in pairs(CreatureConfig.Eggs) do
        config.Eggs[id] = {
            id = egg.id,
            name = egg.name,
            cost = egg.cost,
            description = egg.description,
            allowedElements = egg.allowedElements
        }
    end
    
    return config
end

-- Admin/Debug commands
local ADMIN_USER_IDS = {} -- Add UserIds here: {12345678, 87654321}

local function isAdmin(player)
    return table.find(ADMIN_USER_IDS, player.UserId) ~= nil
end

local function onPlayerCommand(player, message)
    if message:sub(1, 1) ~= "/" then return end
    
    local args = message:split(" ")
    local cmd = args[1]:lower()
    
    -- /givecoins [amount] - Admin only
    if cmd == "/givecoins" then
        if not isAdmin(player) then
            print(string.format("[Admin] Unauthorized attempt by %s", player.Name))
            return
        end
        local session = PlayerData.GetSession(player.UserId)
        if session then
            local amount = tonumber(args[2]) or 1000
            session:AddCoins(amount)
            print(string.format("[Admin] Gave %s %d coins", player.Name, amount))
        end
    end
    
    -- /resetdata - Reset player data (admin only)
    if cmd == "/resetdata" then
        if not isAdmin(player) then
            print(string.format("[Admin] Unauthorized attempt by %s", player.Name))
            return
        end
        local session = PlayerData.GetSession(player.UserId)
        if session then
            session.data = {
                coins = 0,
                pets = {},
                rebirths = 0,
                equipped = nil,
                stats = {
                    totalClicks = 0,
                    totalCoinsEarned = 0,
                    creaturesHatched = 0,
                    joinTime = os.time()
                }
            }
            session:Save()
            print(string.format("[Admin] Reset data for %s", player.Name))
        end
    end
end

-- Admin commands (only works in live game, not Studio)
local success, err = pcall(function()
    Players.PlayerChatted:Connect(onPlayerCommand)
end)
if not success then
    print("[Main] PlayerChatted not available (Studio mode) - admin commands disabled")
end

-- Handle player leaving cleanup
Players.PlayerRemoving:Connect(function(player)
    ClickHandler.CleanupPlayer(player.UserId)
end)

-- Verify RemoteEvents exist and log them
local function verifyRemotes()
    local remotesFolder = ReplicatedStorage:FindFirstChild("CreatureClickerRemotes")
    if remotesFolder then
        print("[Main] ✓ CreatureClickerRemotes folder exists")
        local requiredRemotes = {"ClickRequest", "ClickResponse", "HatchRequest", "HatchResult", "GetPlayerData"}
        for _, remoteName in ipairs(requiredRemotes) do
            local remote = remotesFolder:FindFirstChild(remoteName)
            if remote then
                print(string.format("[Main] ✓ RemoteEvent: %s", remoteName))
            else
                print(string.format("[Main] ✗ MISSING RemoteEvent: %s", remoteName))
            end
        end
    else
        print("[Main] ✗ CreatureClickerRemotes folder NOT FOUND")
    end
end
verifyRemotes()

-- Debug: Monitor player joins and data loading
Players.PlayerAdded:Connect(function(player)
    print(string.format("[Main] Player joined: %s (%d)", player.Name, player.UserId))
    
    -- Wait a bit and check if data loaded
    task.delay(3, function()
        local session = PlayerData.GetSession(player.UserId)
        if session then
            if session.loaded then
                print(string.format("[Main] ✓ Data loaded for %s - Coins: %d", player.Name, session:GetCoins()))
            else
                print(string.format("[Main] ✗ Data NOT loaded for %s (still loading?)", player.Name))
            end
        else
            print(string.format("[Main] ✗ NO SESSION for %s", player.Name))
        end
    end)
end)

print("[Main] Server fully operational")

-- Keep script alive
while true do
    task.wait(60)
    
    -- Health check
    local activeSessions = 0
    for _ in pairs(PlayerData.Sessions) do
        activeSessions = activeSessions + 1
    end
    
    print(string.format("[Health] Active sessions: %d", activeSessions))
end
