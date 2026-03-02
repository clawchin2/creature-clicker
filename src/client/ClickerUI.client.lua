-- Simple working UI for Creature Clicker
print("[ClickerUI] Loading...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get server remotes
local remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes")
local buyEggRemote = remotes:WaitForChild("BuyEgg")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Coin display (moved down to avoid blocking Roblox UI)
local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "Coins"
coinLabel.Size = UDim2.new(0, 200, 0, 50)
coinLabel.Position = UDim2.new(0, 20, 0, 60) -- Moved down from 20 to 60
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "Coins: 5"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 32
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Parent = screenGui

-- Coin icon
local coinIcon = Instance.new("ImageLabel")
coinIcon.Name = "CoinIcon"
coinIcon.Size = UDim2.new(0, 40, 0, 40)
coinIcon.Position = UDim2.new(0, -45, 0, 5)
coinIcon.BackgroundTransparency = 1
coinIcon.Image = "rbxassetid://0" -- Placeholder, can be replaced with actual coin icon
coinIcon.Parent = coinLabel

-- Buy Egg button (below click button)
local buyEggButton = Instance.new("TextButton")
buyEggButton.Name = "BuyEggButton"
buyEggButton.Size = UDim2.new(0, 150, 0, 60)
buyEggButton.Position = UDim2.new(1, -170, 1, -90) -- Below click button
buyEggButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Green
buyEggButton.Text = "Buy Egg (10)"
buyEggButton.TextColor3 = Color3.new(1, 1, 1)
buyEggButton.TextSize = 20
buyEggButton.Font = Enum.Font.GothamBold
buyEggButton.Parent = screenGui

-- Egg button corner radius
local eggCorner = Instance.new("UICorner")
eggCorner.CornerRadius = UDim.new(0, 10)
eggCorner.Parent = buyEggButton

-- Feedback label (above buttons)
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "FeedbackLabel"
feedbackLabel.Size = UDim2.new(0, 300, 0, 40)
feedbackLabel.Position = UDim2.new(1, -245, 1, -135) -- Above buttons
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.Text = ""
feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
feedbackLabel.TextSize = 20
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Parent = screenGui

-- Click button (bottom right corner, round)
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 150, 0, 150)
clickButton.Position = UDim2.new(1, -170, 1, -170) -- Bottom right corner with padding
clickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
clickButton.Text = "CLICK!"
clickButton.TextColor3 = Color3.new(1, 1, 1)
clickButton.TextSize = 40
clickButton.Font = Enum.Font.GothamBlack
clickButton.Parent = screenGui

-- Make button ROUND
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0) -- Circle shape
uiCorner.Parent = clickButton

-- Add shadow/glow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217" -- Shadow/glow image
shadow.ImageColor3 = Color3.fromRGB(0, 100, 200)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1
shadow.Parent = clickButton

-- Add UIStroke for extra glow
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(100, 200, 255)
uiStroke.Thickness = 4
uiStroke.Transparency = 0.3
uiStroke.Parent = clickButton

-- Animation configurations
local normalSize = UDim2.new(0, 150, 0, 150)
local pressedSize = UDim2.new(0, 130, 0, 130) -- Slightly smaller when clicked
local normalColor = Color3.fromRGB(0, 150, 255)
local hoverColor = Color3.fromRGB(50, 180, 255) -- Brighter on hover
local pressedColor = Color3.fromRGB(0, 120, 200) -- Darker when pressed

local tweenInfo = TweenInfo.new(
    0.1, -- Duration
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

-- Hover effects
clickButton.MouseEnter:Connect(function()
    TweenService:Create(clickButton, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
    TweenService:Create(uiStroke, tweenInfo, {Transparency = 0}):Play()
end)

clickButton.MouseLeave:Connect(function()
    TweenService:Create(clickButton, tweenInfo, {BackgroundColor3 = normalColor}):Play()
    TweenService:Create(uiStroke, tweenInfo, {Transparency = 0.3}):Play()
end)

-- Track total coins locally
local totalCoins = 5

-- Click handler with scale animation
clickButton.MouseButton1Down:Connect(function()
    -- Scale down and darken
    TweenService:Create(clickButton, tweenInfo, {
        Size = pressedSize,
        BackgroundColor3 = pressedColor
    }):Play()
end)

clickButton.MouseButton1Up:Connect(function()
    -- Scale back up and brighten
    TweenService:Create(clickButton, tweenInfo, {
        Size = normalSize,
        BackgroundColor3 = hoverColor
    }):Play()
end)

clickButton.MouseButton1Click:Connect(function()
    totalCoins = totalCoins + 1
    coinLabel.Text = "Coins: " .. totalCoins
    
    -- Flash effect on coin label
    local originalColor = coinLabel.TextColor3
    coinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    wait(0.1)
    coinLabel.TextColor3 = originalColor
end)

-- Buy Egg handler
buyEggButton.MouseButton1Click:Connect(function()
    -- Call server to buy egg
    local success, result = pcall(function()
        return buyEggRemote:InvokeServer()
    end)

    if success and result then
        if result.success then
            -- Update coin display
            if result.remainingCoins then
                totalCoins = result.remainingCoins
                coinLabel.Text = "Coins: " .. totalCoins
            end

            -- Show success
            feedbackLabel.Text = "Got: " .. result.creatureName
            feedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            -- Show error
            feedbackLabel.Text = "Need 10 coins"
            feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end

        -- Clear feedback after 2 seconds
        delay(2, function()
            feedbackLabel.Text = ""
        end)
    else
        feedbackLabel.Text = "Error buying egg"
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        delay(2, function()
            feedbackLabel.Text = ""
        end)
    end
end)

print("[ClickerUI] Loaded successfully!")
