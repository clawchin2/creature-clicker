-- Simple working UI for Creature Clicker
print("[ClickerUI] Loading...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get server remotes
local remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 30)
local BuyEgg = remotes:WaitForChild("BuyEgg")
local GetInventory = remotes:WaitForChild("GetInventory")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Coin display
local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "Coins"
coinLabel.Size = UDim2.new(0, 200, 0, 50)
coinLabel.Position = UDim2.new(0, 20, 0, 60)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "Coins: 5"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 32
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Parent = screenGui

-- Inventory button
local invButton = Instance.new("TextButton")
invButton.Name = "InventoryButton"
invButton.Size = UDim2.new(0, 100, 0, 40)
invButton.Position = UDim2.new(0, 20, 0, 120)
invButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
invButton.Text = "Inventory"
invButton.TextColor3 = Color3.new(1, 1, 1)
invButton.TextSize = 18
invButton.Font = Enum.Font.GothamBold
invButton.Parent = screenGui

local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = invButton

-- Click button (bottom right)
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 150, 0, 150)
clickButton.Position = UDim2.new(1, -170, 1, -170)
clickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
clickButton.Text = "CLICK!"
clickButton.TextColor3 = Color3.new(1, 1, 1)
clickButton.TextSize = 40
clickButton.Font = Enum.Font.GothamBlack
clickButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = clickButton

-- Buy Egg Button (above click button)
local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyEggButton"
buyButton.Size = UDim2.new(0, 150, 0, 50)
buyButton.Position = UDim2.new(1, -170, 1, -240)
buyButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
buyButton.Text = "Buy Egg (10)"
buyButton.TextColor3 = Color3.new(1, 1, 1)
buyButton.TextSize = 18
buyButton.Font = Enum.Font.GothamBold
buyButton.Parent = screenGui

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 10)
buyCorner.Parent = buyButton

-- Track coins
local totalCoins = 5
local creatures = {}

-- Click handler (local for now)
clickButton.MouseButton1Click:Connect(function()
    totalCoins = totalCoins + 1
    coinLabel.Text = "Coins: " .. totalCoins
    print("Clicked! Coins: " .. totalCoins)
end)

-- Buy Egg handler (server connected)
buyButton.MouseButton1Click:Connect(function()
    local success, result = pcall(function()
        return BuyEgg:InvokeServer()
    end)
    
    if success and result and result.success then
        totalCoins = result.remainingCoins
        coinLabel.Text = "Coins: " .. totalCoins
        table.insert(creatures, result.creatureName)
        print("Got: " .. result.creatureName)
    else
        print("Need 10 coins")
    end
end)

-- Inventory handler
invButton.MouseButton1Click:Connect(function()
    print("=== INVENTORY ===")
    if #creatures == 0 then
        print("No creatures yet!")
    else
        for i, creature in ipairs(creatures) do
            print(i .. ". " .. creature)
        end
    end
    print("=================")
end)

print("[ClickerUI] Loaded successfully!")
