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

-- Track coins
local totalCoins = 5

-- Click handler
clickButton.MouseButton1Click:Connect(function()
    totalCoins = totalCoins + 1
    coinLabel.Text = "Coins: " .. totalCoins
    print("Clicked! Coins: " .. totalCoins)
end)

print("[ClickerUI] Loaded successfully!")
