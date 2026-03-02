-- Simple working UI for Creature Clicker
print("[ClickerUI] Loading...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get server remotes
local remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 30)
local Click = remotes:WaitForChild("Click")
local BuyEgg = remotes:WaitForChild("BuyEgg")
local GetInventory = remotes:WaitForChild("GetInventory")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Coin display (top left, below Roblox UI)
local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "Coins"
coinLabel.Size = UDim2.new(0, 200, 0, 50)
coinLabel.Position = UDim2.new(0, 20, 0, 80)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "Coins: 5"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 32
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Parent = screenGui

-- Inventory button (top left, below coins)
local invButton = Instance.new("TextButton")
invButton.Name = "InventoryButton"
invButton.Size = UDim2.new(0, 120, 0, 40)
invButton.Position = UDim2.new(0, 20, 0, 140)
invButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
invButton.Text = "Inventory"
invButton.TextColor3 = Color3.new(1, 1, 1)
invButton.TextSize = 18
invButton.Font = Enum.Font.GothamBold
invButton.Parent = screenGui

local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = invButton

-- Click button (bottom left, NOT covering player)
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 140, 0, 50)
clickButton.Position = UDim2.new(0, 20, 1, -70) -- Bottom left corner
clickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
clickButton.Text = "CLICK!"
clickButton.TextColor3 = Color3.new(1, 1, 1)
clickButton.TextSize = 24
clickButton.Font = Enum.Font.GothamBold
clickButton.Parent = screenGui

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 10)
clickCorner.Parent = clickButton

-- Egg Type Buttons Container Frame (right side)
local eggFrame = Instance.new("Frame")
eggFrame.Name = "EggFrame"
eggFrame.Size = UDim2.new(0, 120, 0, 140)
eggFrame.Position = UDim2.new(1, -140, 0, 100) -- Top right area
eggFrame.BackgroundTransparency = 1
eggFrame.Parent = screenGui

-- Basic Egg Button (10 coins) - Green
local basicButton = Instance.new("TextButton")
basicButton.Name = "BasicEggButton"
basicButton.Size = UDim2.new(0, 100, 0, 40)
basicButton.Position = UDim2.new(0, 10, 0, 0)
basicButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
basicButton.Text = "Basic (10)"
basicButton.TextColor3 = Color3.new(1, 1, 1)
basicButton.TextSize = 14
basicButton.Font = Enum.Font.GothamBold
basicButton.Parent = eggFrame

local basicCorner = Instance.new("UICorner")
basicCorner.CornerRadius = UDim.new(0, 8)
basicCorner.Parent = basicButton

-- Fire Egg Button (50 coins) - Red/Orange
local fireButton = Instance.new("TextButton")
fireButton.Name = "FireEggButton"
fireButton.Size = UDim2.new(0, 100, 0, 40)
fireButton.Position = UDim2.new(0, 10, 0, 50)
fireButton.BackgroundColor3 = Color3.fromRGB(255, 100, 30)
fireButton.Text = "Fire (50)"
fireButton.TextColor3 = Color3.new(1, 1, 1)
fireButton.TextSize = 14
fireButton.Font = Enum.Font.GothamBold
fireButton.Parent = eggFrame

local fireCorner = Instance.new("UICorner")
fireCorner.CornerRadius = UDim.new(0, 8)
fireCorner.Parent = fireButton

-- Void Egg Button (150 coins) - Purple
local voidButton = Instance.new("TextButton")
voidButton.Name = "VoidEggButton"
voidButton.Size = UDim2.new(0, 100, 0, 40)
voidButton.Position = UDim2.new(0, 10, 0, 100)
voidButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
voidButton.Text = "Void (150)"
voidButton.TextColor3 = Color3.new(1, 1, 1)
voidButton.TextSize = 14
voidButton.Font = Enum.Font.GothamBold
voidButton.Parent = eggFrame

local voidCorner = Instance.new("UICorner")
voidCorner.CornerRadius = UDim.new(0, 8)
voidCorner.Parent = voidButton

-- Status label (center top, for feedback)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 400, 0, 40)
statusLabel.Position = UDim2.new(0.5, -200, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 20
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = screenGui

-- Track coins and creatures
local totalCoins = 5
local creatures = {}

-- Click handler (server-connected)
clickButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return Click:InvokeServer()
    end)
    
    if success and result and result.success then
        totalCoins = result.totalCoins
        coinLabel.Text = "Coins: " .. totalCoins
        print("Clicked! Earned: " .. result.earned .. ", Total: " .. totalCoins)
    else
        print("Click failed")
    end
end)

-- Helper function to show status with rarity
local function showHatchResult(creatureName, rarity)
    local rarityColors = {
        Common = Color3.fromRGB(200, 200, 200),
        Uncommon = Color3.fromRGB(100, 255, 100),
        Rare = Color3.fromRGB(100, 150, 255),
        Epic = Color3.fromRGB(200, 100, 255),
        Legendary = Color3.fromRGB(255, 200, 50)
    }
    
    statusLabel.Text = "Got: " .. creatureName .. " (" .. rarity .. ")"
    statusLabel.TextColor3 = rarityColors[rarity] or Color3.fromRGB(255, 255, 255)
    wait(2)
    statusLabel.Text = ""
end

-- Basic Egg handler
basicButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return BuyEgg:InvokeServer("basic")
    end)
    
    if success and result and result.success then
        totalCoins = result.remainingCoins
        coinLabel.Text = "Coins: " .. totalCoins
        table.insert(creatures, result.creatureName)
        showHatchResult(result.creatureName, result.rarity or "Common")
    else
        statusLabel.Text = "Need 10 coins"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        statusLabel.Text = ""
    end
end)

-- Fire Egg handler
fireButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return BuyEgg:InvokeServer("fire")
    end)
    
    if success and result and result.success then
        totalCoins = result.remainingCoins
        coinLabel.Text = "Coins: " .. totalCoins
        table.insert(creatures, result.creatureName)
        showHatchResult(result.creatureName, result.rarity or "Rare")
    else
        statusLabel.Text = "Need 50 coins"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        statusLabel.Text = ""
    end
end)

-- Void Egg handler
voidButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return BuyEgg:InvokeServer("void")
    end)
    
    if success and result and result.success then
        totalCoins = result.remainingCoins
        coinLabel.Text = "Coins: " .. totalCoins
        table.insert(creatures, result.creatureName)
        showHatchResult(result.creatureName, result.rarity or "Epic")
    else
        statusLabel.Text = "Need 150 coins"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        statusLabel.Text = ""
    end
end)

-- Inventory handler
invButton.MouseButton1Click:Connect(function()
    print("=== INVENTORY ===")
    if #creatures == 0 then
        print("No creatures yet!")
        statusLabel.Text = "No creatures yet!"
    else
        for i, creature in ipairs(creatures) do
            print(i .. ". " .. creature)
        end
        statusLabel.Text = "Creatures: " .. #creatures
    end
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    wait(2)
    statusLabel.Text = ""
    print("=================")
end)

print("[ClickerUI] Loaded successfully!")
