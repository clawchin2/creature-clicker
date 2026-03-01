--[[
    PlayerData Module
    Handles player data management, DataStore save/load
    Data structure: {coins: number, pets: {id: count}, rebirths: number, equipped: string}
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PlayerData = {}
PlayerData.__index = PlayerData

-- DataStore
local CreatureDataStore = DataStoreService:GetDataStore("CreatureClickerData_v1")

-- Active player sessions
PlayerData.Sessions = {}

-- Constants
local AUTO_SAVE_INTERVAL = 60 -- seconds
local BASE_COINS_PER_CLICK = 1

-- Default data template
local DEFAULT_DATA = {
    coins = 0,
    pets = {}, -- {creatureId = count}
    rebirths = 0,
    equipped = nil, -- equipped pet ID
    stats = {
        totalClicks = 0,
        totalCoinsEarned = 0,
        creaturesHatched = 0,
        joinTime = 0
    }
}

-- Create new player data session
function PlayerData.new(player)
    local self = setmetatable({}, PlayerData)
    
    self.player = player
    self.userId = player.UserId
    self.data = nil
    self.loaded = false
    self.autoSaveConnection = nil
    self.lastSave = tick()
    
    return self
end

-- Load data from DataStore
function PlayerData:Load()
    local success, result = pcall(function()
        return CreatureDataStore:GetAsync(tostring(self.userId))
    end)
    
    if success then
        if result then
            -- Merge with defaults to handle new fields
            self.data = self:MergeWithDefaults(result)
        else
            -- New player
            self.data = table.clone(DEFAULT_DATA)
            self.data.stats.joinTime = os.time()
        end
        
        self.loaded = true
        print(string.format("[PlayerData] Loaded data for %s (UserId: %d)", self.player.Name, self.userId))
        return true
    else
        warn(string.format("[PlayerData] Failed to load data for %s: %s", self.player.Name, tostring(result)))
        self.data = table.clone(DEFAULT_DATA)
        self.loaded = false
        return false
    end
end

-- Merge saved data with defaults
function PlayerData:MergeWithDefaults(savedData)
    local merged = table.clone(DEFAULT_DATA)
    
    for key, value in pairs(savedData) do
        if typeof(value) == "table" and typeof(merged[key]) == "table" then
            -- Deep merge for tables
            for k, v in pairs(value) do
                merged[key][k] = v
            end
        else
            merged[key] = value
        end
    end
    
    return merged
end

-- Save data to DataStore
function PlayerData:Save()
    if not self.loaded or not self.data then
        warn(string.format("[PlayerData] Cannot save - data not loaded for %s", self.player.Name))
        return false
    end
    
    local success, result = pcall(function()
        CreatureDataStore:SetAsync(tostring(self.userId), self.data)
    end)
    
    if success then
        self.lastSave = tick()
        print(string.format("[PlayerData] Saved data for %s", self.player.Name))
        return true
    else
        warn(string.format("[PlayerData] Failed to save data for %s: %s", self.player.Name, tostring(result)))
        return false
    end
end

-- Start auto-save
function PlayerData:StartAutoSave()
    if self.autoSaveConnection then
        self.autoSaveConnection:Disconnect()
    end
    
    self.autoSaveConnection = task.spawn(function()
        while self.player and self.player.Parent do
            task.wait(AUTO_SAVE_INTERVAL)
            if self.player and self.player.Parent then
                self:Save()
            end
        end
    end)
end

-- Stop auto-save
function PlayerData:StopAutoSave()
    if self.autoSaveConnection then
        -- Connection auto-clears when player leaves
        self.autoSaveConnection = nil
    end
end

-- Cleanup on player leave
function PlayerData:Cleanup()
    self:StopAutoSave()
    self:Save() -- Final save
    PlayerData.Sessions[self.userId] = nil
end

-- Get coins
function PlayerData:GetCoins()
    return self.data and self.data.coins or 0
end

-- Add coins
function PlayerData:AddCoins(amount)
    if not self.data then return 0 end
    
    self.data.coins = self.data.coins + amount
    self.data.stats.totalCoinsEarned = self.data.stats.totalCoinsEarned + amount
    
    return self.data.coins
end

-- Remove coins (returns true if successful)
function PlayerData:RemoveCoins(amount)
    if not self.data then return false end
    if self.data.coins < amount then return false end
    
    self.data.coins = self.data.coins - amount
    return true
end

-- Get pets
function PlayerData:GetPets()
    return self.data and self.data.pets or {}
end

-- Add pet to inventory
function PlayerData:AddPet(creatureId)
    if not self.data then return false end
    
    if not self.data.pets[creatureId] then
        self.data.pets[creatureId] = 0
    end
    
    self.data.pets[creatureId] = self.data.pets[creatureId] + 1
    self.data.stats.creaturesHatched = self.data.stats.creaturesHatched + 1
    
    -- Auto-equip if first pet
    if not self.data.equipped then
        self:EquipPet(creatureId)
    end
    
    return true
end

-- Equip a pet
function PlayerData:EquipPet(creatureId)
    if not self.data then return false end
    if not self.data.pets[creatureId] or self.data.pets[creatureId] <= 0 then
        return false
    end
    
    self.data.equipped = creatureId
    return true
end

-- Get equipped pet
function PlayerData:GetEquippedPet()
    return self.data and self.data.equipped
end

-- Unequip pet
function PlayerData:UnequipPet()
    if not self.data then return false end
    self.data.equipped = nil
    return true
end

-- Get rebirth count
function PlayerData:GetRebirths()
    return self.data and self.data.rebirths or 0
end

-- Add rebirth
function PlayerData:AddRebirth()
    if not self.data then return 0 end
    self.data.rebirths = self.data.rebirths + 1
    return self.data.rebirths
end

-- Get click multiplier from equipped pet
function PlayerData:GetClickMultiplier(creatureConfig)
    local equipped = self:GetEquippedPet()
    if not equipped then return 1 end
    
    local creature = creatureConfig:GetCreatureById(equipped)
    if not creature then return 1 end
    
    return creature.multiplier
end

-- Get passive income from all pets
function PlayerData:GetPassiveIncome(creatureConfig)
    local total = 0
    local pets = self:GetPets()
    
    for creatureId, count in pairs(pets) do
        local creature = creatureConfig:GetCreatureById(creatureId)
        if creature then
            -- Passive income = 10% of click value per pet
            total = total + (creature.multiplier * count * 0.1)
        end
    end
    
    return math.floor(total * 10) / 10 -- Round to 1 decimal
end

-- Increment click stat
function PlayerData:RecordClick()
    if not self.data then return end
    self.data.stats.totalClicks = self.data.stats.totalClicks + 1
end

-- Get stats
function PlayerData:GetStats()
    return self.data and self.data.stats or {}
end

-- Static methods

function PlayerData.GetSession(userId)
    return PlayerData.Sessions[userId]
end

function PlayerData.GetOrCreateSession(player)
    local session = PlayerData.Sessions[player.UserId]
    if not session then
        session = PlayerData.new(player)
        PlayerData.Sessions[player.UserId] = session
    end
    return session
end

-- Initialize player
function PlayerData.OnPlayerJoin(player)
    local session = PlayerData.GetOrCreateSession(player)
    session:Load()
    session:StartAutoSave()
    
    -- Fire event for other systems
    -- (Will be connected to RemoteEvents)
    
    return session
end

-- Cleanup player
function PlayerData.OnPlayerLeave(player)
    local session = PlayerData.Sessions[player.UserId]
    if session then
        session:Cleanup()
    end
end

-- Initialize module
function PlayerData.Init()
    Players.PlayerAdded:Connect(PlayerData.OnPlayerJoin)
    Players.PlayerRemoving:Connect(PlayerData.OnPlayerLeave)
    
    -- Handle existing players (for hot-reload during dev)
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerData.OnPlayerJoin(player)
    end
    
    print("[PlayerData] Module initialized")
end

return PlayerData
