--[[
    HatchSystem Module
    Handles egg hatching with RNG rarity system
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local HatchSystem = {}

-- RNG state (use Random for better distribution)
local rng = Random.new()

-- RemoteEvents
local Remotes = {}

function HatchSystem.Init(playerDataModule, creatureConfig)
    HatchSystem.PlayerData = playerDataModule
    HatchSystem.CreatureConfig = creatureConfig
    
    -- Get or create remotes folder
    local remotesFolder = ReplicatedStorage:WaitForChild("CreatureClickerRemotes")
    
    -- Create HatchRequest remote
    Remotes.HatchRequest = remotesFolder:FindFirstChild("HatchRequest")
    if not Remotes.HatchRequest then
        Remotes.HatchRequest = Instance.new("RemoteEvent")
        Remotes.HatchRequest.Name = "HatchRequest"
        Remotes.HatchRequest.Parent = remotesFolder
    end
    
    -- Create HatchResult remote
    Remotes.HatchResult = remotesFolder:FindFirstChild("HatchResult")
    if not Remotes.HatchResult then
        Remotes.HatchResult = Instance.new("RemoteEvent")
        Remotes.HatchResult.Name = "HatchResult"
        Remotes.HatchResult.Parent = remotesFolder
    end
    
    -- Create GetEggsInfo remote
    Remotes.GetEggsInfo = remotesFolder:FindFirstChild("GetEggsInfo")
    if not Remotes.GetEggsInfo then
        Remotes.GetEggsInfo = Instance.new("RemoteFunction")
        Remotes.GetEggsInfo.Name = "GetEggsInfo"
        Remotes.GetEggsInfo.Parent = remotesFolder
    end
    
    -- Connect handlers
    Remotes.HatchRequest.OnServerEvent:Connect(HatchSystem.OnHatchRequest)
    Remotes.GetEggsInfo.OnServerInvoke = HatchSystem.OnGetEggsInfo
    
    print("[HatchSystem] Module initialized")
    print(string.format("[HatchSystem] ✓ HatchRequest: %s", Remotes.HatchRequest and "created" or "FAILED"))
    print(string.format("[HatchSystem] ✓ HatchResult: %s", Remotes.HatchResult and "created" or "FAILED"))
end

-- Get modified rarity weights based on egg type
function HatchSystem.GetModifiedWeights(eggType)
    local config = HatchSystem.CreatureConfig
    local eggConfig = config.Eggs[eggType]
    
    local weights = {
        Common = config.Rarities.Common.weight,
        Uncommon = config.Rarities.Uncommon.weight,
        Rare = config.Rarities.Rare.weight,
        Epic = config.Rarities.Epic.weight,
        Legendary = config.Rarities.Legendary.weight
    }
    
    -- Apply modifiers if egg has them
    if eggConfig and eggConfig.rarityModifiers then
        for rarity, newWeight in pairs(eggConfig.rarityModifiers) do
            if weights[rarity] then
                weights[rarity] = newWeight
            end
        end
    end
    
    return weights
end

-- Roll for rarity (with optional forceRare for first egg guarantee)
function HatchSystem.RollRarity(eggType, forceRare)
    -- First egg guarantee: always give Rare rarity
    if forceRare then
        return "Rare"
    end
    
    local weights = HatchSystem.GetModifiedWeights(eggType)
    local totalWeight = 0
    
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local roll = rng:NextNumber(0, totalWeight)
    local cumulative = 0
    
    cumulative = cumulative + weights.Common
    if roll <= cumulative then return "Common" end
    
    cumulative = cumulative + weights.Uncommon
    if roll <= cumulative then return "Uncommon" end
    
    cumulative = cumulative + weights.Rare
    if roll <= cumulative then return "Rare" end
    
    cumulative = cumulative + weights.Epic
    if roll <= cumulative then return "Epic" end
    
    return "Legendary"
end

-- Get random creature from element and rarity
function HatchSystem.GetRandomCreature(element, rarity)
    local config = HatchSystem.CreatureConfig
    local candidates = {}
    
    for id, creature in pairs(config.Creatures) do
        if creature.element == element and creature.rarity == rarity then
            table.insert(candidates, creature)
        end
    end
    
    if #candidates == 0 then
        -- Fallback: return any creature of that rarity
        for id, creature in pairs(config.Creatures) do
            if creature.rarity == rarity then
                table.insert(candidates, creature)
            end
        end
    end
    
    if #candidates > 0 then
        return candidates[rng:NextInteger(1, #candidates)]
    end
    
    return nil
end

-- Hatch an egg
function HatchSystem.HatchEgg(player, eggType)
    local config = HatchSystem.CreatureConfig
    local eggConfig = config.Eggs[eggType]
    
    if not eggConfig then
        return {success = false, error = "Invalid egg type"}
    end
    
    -- Get player session
    local session = HatchSystem.PlayerData.GetSession(player.UserId)
    if not session or not session.loaded then
        return {success = false, error = "Data not loaded"}
    end
    
    -- Check if player has enough coins
    if session:GetCoins() < eggConfig.cost then
        return {success = false, error = "Not enough coins"}
    end
    
    -- Deduct coins
    local paid = session:RemoveCoins(eggConfig.cost)
    if not paid then
        return {success = false, error = "Payment failed"}
    end
    
    -- Determine which element to hatch
    local element
    if eggConfig.allowedElements and #eggConfig.allowedElements == 1 then
        element = eggConfig.allowedElements[1]
    else
        -- Random element from allowed list
        local elements = eggConfig.allowedElements or {"Fire", "Water", "Earth", "Air", "Void"}
        element = elements[rng:NextInteger(1, #elements)]
    end
    
    -- Check if this is the player's first egg ever
    local isFirstEgg = session:IsFirstEgg()
    
    -- Roll rarity (guarantee Rare for first egg)
    local rarity = HatchSystem.RollRarity(eggType, isFirstEgg)
    
    -- Mark first egg as hatched
    if isFirstEgg then
        session:MarkFirstEggHatched()
    end
    
    -- Get creature
    local creature = HatchSystem.GetRandomCreature(element, rarity)
    if not creature then
        -- Refund and error
        session:AddCoins(eggConfig.cost)
        return {success = false, error = "Hatch failed - creature not found"}
    end
    
    -- Add to inventory
    session:AddPet(creature.id)
    
    -- Return result
    return {
        success = true,
        creature = {
            id = creature.id,
            name = creature.name,
            element = creature.element,
            rarity = creature.rarity,
            multiplier = creature.multiplier,
            description = creature.description
        },
        remainingCoins = session:GetCoins()
    }
end

-- Handle hatch request
function HatchSystem.OnHatchRequest(player, eggType)
    -- Validate egg type
    if typeof(eggType) ~= "string" then
        Remotes.HatchResult:FireClient(player, {
            success = false,
            error = "Invalid request"
        })
        return
    end
    
    -- Process hatch
    local result = HatchSystem.HatchEgg(player, eggType)
    
    -- Send result to client
    Remotes.HatchResult:FireClient(player, result)
    
    -- Log
    if result.success then
        print(string.format("[HatchSystem] %s hatched %s (%s %s) from %s egg",
            player.Name,
            result.creature.name,
            result.creature.rarity,
            result.creature.element,
            eggType
        ))
    else
        print(string.format("[HatchSystem] %s hatch failed: %s", player.Name, result.error))
    end
end

-- Get eggs info for shop display
function HatchSystem.OnGetEggsInfo(player)
    local config = HatchSystem.CreatureConfig
    local eggsInfo = {}
    
    for eggId, eggData in pairs(config.Eggs) do
        local info = {
            id = eggData.id,
            name = eggData.name,
            cost = eggData.cost,
            description = eggData.description,
            allowedElements = eggData.allowedElements,
            rarityChances = {}
        }
        
        -- Calculate actual chances with modifiers
        local weights = HatchSystem.GetModifiedWeights(eggId)
        local totalWeight = 0
        for _, w in pairs(weights) do
            totalWeight = totalWeight + w
        end
        
        for rarity, weight in pairs(weights) do
            info.rarityChances[rarity] = math.round((weight / totalWeight) * 1000) / 10 -- One decimal
        end
        
        table.insert(eggsInfo, info)
    end
    
    -- Sort by cost
    table.sort(eggsInfo, function(a, b)
        return a.cost < b.cost
    end)
    
    return eggsInfo
end

-- Get player's pets with full creature data
function HatchSystem.GetPlayerPets(player)
    local session = HatchSystem.PlayerData.GetSession(player.UserId)
    if not session then return {} end
    
    local pets = session:GetPets()
    local result = {}
    
    for creatureId, count in pairs(pets) do
        local creature = HatchSystem.CreatureConfig:GetCreatureById(creatureId)
        if creature then
            table.insert(result, {
                id = creature.id,
                name = creature.name,
                element = creature.element,
                rarity = creature.rarity,
                multiplier = creature.multiplier,
                description = creature.description,
                count = count,
                equipped = (session:GetEquippedPet() == creatureId)
            })
        end
    end
    
    -- Sort by rarity then name
    local rarityOrder = {Legendary = 1, Epic = 2, Rare = 3, Uncommon = 4, Common = 5}
    table.sort(result, function(a, b)
        local aOrder = rarityOrder[a.rarity] or 99
        local bOrder = rarityOrder[b.rarity] or 99
        if aOrder ~= bOrder then
            return aOrder < bOrder
        end
        return a.name < b.name
    end)
    
    return result
end

-- Equip pet request handler (to be called from main script)
function HatchSystem.HandleEquipRequest(player, creatureId)
    local session = HatchSystem.PlayerData.GetSession(player.UserId)
    if not session then return false end
    
    local success = session:EquipPet(creatureId)
    return success
end

-- Unequip pet request handler
function HatchSystem.HandleUnequipRequest(player)
    local session = HatchSystem.PlayerData.GetSession(player.UserId)
    if not session then return false end
    
    local success = session:UnequipPet()
    return success
end

return HatchSystem
