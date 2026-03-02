--[[
    PassiveIncome Module
    Handles passive coin generation from owned pets
    Awards coins every 5 seconds based on pet multipliers
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PassiveIncome = {}

-- Configuration
local INCOME_INTERVAL = 5 -- seconds between payouts
local INCOME_PER_MULTIPLIER = 0.1 -- 10% of click value per interval per pet

-- Runtime
local incomeLoopRunning = false
local Remotes = {}

function PassiveIncome.Init(playerDataModule, creatureConfig)
    PassiveIncome.PlayerData = playerDataModule
    PassiveIncome.CreatureConfig = creatureConfig
    
    -- Get or create remotes
    local remotesFolder = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 30)
    
    Remotes.PassiveIncome = remotesFolder:FindFirstChild("PassiveIncome")
    if not Remotes.PassiveIncome then
        Remotes.PassiveIncome = Instance.new("RemoteEvent")
        Remotes.PassiveIncome.Name = "PassiveIncome"
        Remotes.PassiveIncome.Parent = remotesFolder
    end
    
    -- Start income loop
    PassiveIncome.StartIncomeLoop()
    
    print("[PassiveIncome] Module initialized")
end

-- Calculate passive income for a session
function PassiveIncome.CalculateIncome(session)
    if not session then return 0 end
    
    local pets = session:GetPets()
    local totalIncome = 0
    
    for creatureId, count in pairs(pets) do
        local creature = PassiveIncome.CreatureConfig:GetCreatureById(creatureId)
        if creature then
            -- Each pet gives 10% of its multiplier as passive income per interval
            totalIncome = totalIncome + (creature.multiplier * count * INCOME_PER_MULTIPLIER)
        end
    end
    
    -- Apply rebirth multiplier
    local rebirthMultiplier = 1 + (session:GetRebirths() * 0.1)
    totalIncome = totalIncome * rebirthMultiplier
    
    return math.floor(totalIncome)
end

-- Process income for all players
function PassiveIncome.ProcessAllPlayers()
    local sessions = PassiveIncome.PlayerData.Sessions
    
    for userId, session in pairs(sessions) do
        if session.loaded and session.player and session.player.Parent then
            local income = PassiveIncome.CalculateIncome(session)
            
            if income > 0 then
                local newTotal = session:AddCoins(income)
                
                -- Notify client
                Remotes.PassiveIncome:FireClient(session.player, {
                    amount = income,
                    totalCoins = newTotal,
                    interval = INCOME_INTERVAL
                })
            end
        end
    end
end

-- Start the income loop
function PassiveIncome.StartIncomeLoop()
    if incomeLoopRunning then return end
    
    incomeLoopRunning = true
    
    task.spawn(function()
        while incomeLoopRunning do
            task.wait(INCOME_INTERVAL)
            
            if not incomeLoopRunning then break end
            
            local success, err = pcall(PassiveIncome.ProcessAllPlayers)
            if not success then
                warn("[PassiveIncome] Error processing income: " .. tostring(err))
            end
        end
    end)
    
    print(string.format("[PassiveIncome] Started income loop (interval: %ds)", INCOME_INTERVAL))
end

-- Stop the income loop
function PassiveIncome.StopIncomeLoop()
    incomeLoopRunning = false
end

-- Get income preview for a player (for UI display)
function PassiveIncome.GetIncomePreview(player)
    local session = PassiveIncome.PlayerData.GetSession(player.UserId)
    if not session then return 0 end
    
    local income = PassiveIncome.CalculateIncome(session)
    return {
        perInterval = income,
        perMinute = income * (60 / INCOME_INTERVAL),
        perHour = income * (3600 / INCOME_INTERVAL)
    }
end

return PassiveIncome
