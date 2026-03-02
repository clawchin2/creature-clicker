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

-- Buy Egg Button (bottom right, NOT covering player)
local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyEggButton"
buyButton.Size = UDim2.new(0, 140, 0, 50)
buyButton.Position = UDim2.new(1, -160, 1, -70) -- Bottom right corner
buyButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
buyButton.Text = "Buy Egg (10)"
buyButton.TextColor3 = Color3.new(1, 1, 1)
buyButton.TextSize = 16
buyButton.Font = Enum.Font.GothamBold
buyButton.Parent = screenGui

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 10)
buyCorner.Parent = buyButton

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

-- Buy Egg handler
buyButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return BuyEgg:InvokeServer()
    end)
    
    if success and result and result.success then
        totalCoins = result.remainingCoins
        coinLabel.Text = "Coins: " .. totalCoins
        table.insert(creatures, result.creatureName)
        statusLabel.Text = "Got: " .. result.creatureName
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        wait(2)
        statusLabel.Text = ""
    else
        statusLabel.Text = "Need 10 coins"
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
