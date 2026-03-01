--[[
    ClickHandler Module
    Server-validated clicking system with rate limiting
    Rate limit: 10 clicks/second per player
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClickHandler = {}

-- Configuration
local MAX_CLICKS_PER_SECOND = 10
local CLICK_WINDOW = 1 -- second
local BASE_COINS_PER_CLICK = 1

-- Rate limiting tracking
local clickHistory = {} -- {userId = {timestamps}}

-- RemoteEvents (will be created if they don't exist)
local Remotes = {}

function ClickHandler.Init(playerDataModule, creatureConfig)
    ClickHandler.PlayerData = playerDataModule
    ClickHandler.CreatureConfig = creatureConfig
    
    -- Create or get RemoteEvents folder
    local remotesFolder = ReplicatedStorage:FindFirstChild("CreatureClickerRemotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "CreatureClickerRemotes"
        remotesFolder.Parent = ReplicatedStorage
    end
    
    -- Create ClickRequest remote
    Remotes.ClickRequest = remotesFolder:FindFirstChild("ClickRequest")
    if not Remotes.ClickRequest then
        Remotes.ClickRequest = Instance.new("RemoteEvent")
        Remotes.ClickRequest.Name = "ClickRequest"
        Remotes.ClickRequest.Parent = remotesFolder
    end
    
    -- Create ClickResponse remote
    Remotes.ClickResponse = remotesFolder:FindFirstChild("ClickResponse")
    if not Remotes.ClickResponse then
        Remotes.ClickResponse = Instance.new("RemoteEvent")
        Remotes.ClickResponse.Name = "ClickResponse"
        Remotes.ClickResponse.Parent = remotesFolder
    end
    
    -- Create GetPlayerData remote
    Remotes.GetPlayerData = remotesFolder:FindFirstChild("GetPlayerData")
    if not Remotes.GetPlayerData then
        Remotes.GetPlayerData = Instance.new("RemoteFunction")
        Remotes.GetPlayerData.Name = "GetPlayerData"
        Remotes.GetPlayerData.Parent = remotesFolder
    end
    
    -- Connect handlers
    Remotes.ClickRequest.OnServerEvent:Connect(ClickHandler.OnClickRequest)
    Remotes.GetPlayerData.OnServerInvoke = ClickHandler.OnGetPlayerDataRequest
    
    print("[ClickHandler] Module initialized")
end

-- Check rate limit for a player
function ClickHandler.CheckRateLimit(userId)
    local now = tick()
    
    -- Initialize history if needed
    if not clickHistory[userId] then
        clickHistory[userId] = {}
    end
    
    local history = clickHistory[userId]
    
    -- Remove old timestamps outside the window
    local cutoff = now - CLICK_WINDOW
    local i = 1
    while i <= #history do
        if history[i] < cutoff then
            table.remove(history, i)
        else
            i = i + 1
        end
    end
    
    -- Check if under limit
    if #history >= MAX_CLICKS_PER_SECOND then
        return false, "Rate limit exceeded"
    end
    
    -- Record this click
    table.insert(history, now)
    return true
end

-- Calculate coins for a click
function ClickHandler.CalculateClickReward(session)
    if not session then return 0 end
    
    local baseCoins = BASE_COINS_PER_CLICK
    local multiplier = session:GetClickMultiplier(ClickHandler.CreatureConfig)
    local rebirthMultiplier = 1 + (session:GetRebirths() * 0.1) -- 10% per rebirth
    
    local total = baseCoins * multiplier * rebirthMultiplier
    return math.floor(total)
end

-- Handle click request from client
function ClickHandler.OnClickRequest(player)
    local userId = player.UserId
    
    -- Check rate limit
    local allowed, reason = ClickHandler.CheckRateLimit(userId)
    if not allowed then
        Remotes.ClickResponse:FireClient(player, {
            success = false,
            error = reason,
            coinsEarned = 0,
            totalCoins = 0
        })
        return
    end
    
    -- Get player session
    local session = ClickHandler.PlayerData.GetSession(userId)
    if not session or not session.loaded then
        Remotes.ClickResponse:FireClient(player, {
            success = false,
            error = "Data not loaded",
            coinsEarned = 0,
            totalCoins = 0
        })
        return
    end
    
    -- Calculate reward
    local coinsEarned = ClickHandler.CalculateClickReward(session)
    
    -- Add coins
    local newTotal = session:AddCoins(coinsEarned)
    session:RecordClick()
    
    -- Send response
    Remotes.ClickResponse:FireClient(player, {
        success = true,
        coinsEarned = coinsEarned,
        totalCoins = newTotal,
        multiplier = session:GetClickMultiplier(ClickHandler.CreatureConfig)
    })
    
    -- Debug
    -- print(string.format("[ClickHandler] %s clicked: +%d coins (total: %d)", player.Name, coinsEarned, newTotal))
end

-- Handle data request from client
function ClickHandler.OnGetPlayerDataRequest(player)
    local session = ClickHandler.PlayerData.GetSession(player.UserId)
    if not session or not session.data then
        return nil
    end
    
    -- Return safe copy of data
    return {
        coins = session.data.coins,
        pets = session.data.pets,
        rebirths = session.data.rebirths,
        equipped = session.data.equipped,
        passiveIncome = session:GetPassiveIncome(ClickHandler.CreatureConfig),
        clickMultiplier = session:GetClickMultiplier(ClickHandler.CreatureConfig)
    }
end

-- Get rate limit info (for debugging)
function ClickHandler.GetRateLimitInfo(userId)
    local history = clickHistory[userId]
    if not history then
        return {count = 0, limit = MAX_CLICKS_PER_SECOND}
    end
    
    -- Clean old entries
    local now = tick()
    local cutoff = now - CLICK_WINDOW
    local count = 0
    for _, timestamp in ipairs(history) do
        if timestamp >= cutoff then
            count = count + 1
        end
    end
    
    return {
        count = count,
        limit = MAX_CLICKS_PER_SECOND,
        window = CLICK_WINDOW
    }
end

-- Cleanup when player leaves
function ClickHandler.CleanupPlayer(userId)
    clickHistory[userId] = nil
end

return ClickHandler
