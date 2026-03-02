-- Simple working UI for Creature Clicker
print("[ClickerUI] Loading...")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

-- Make button round
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

-- Click handler
clickButton.MouseButton1Click:Connect(function()
    totalCoins = totalCoins + 1
    coinLabel.Text = "Coins: " .. totalCoins
    print("Clicked! Coins: " .. totalCoins)
end)

-- Buy Egg handler (local only for now)
buyButton.MouseButton1Click:Connect(function()
    if totalCoins >= 10 then
        totalCoins = totalCoins - 10
        coinLabel.Text = "Coins: " .. totalCoins
        print("Bought egg! Got: Froggle")
    else
        print("Need 10 coins")
    end
end)

print("[ClickerUI] Loaded successfully!")
