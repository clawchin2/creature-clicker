-- ClickerUILogic.client.lua
-- Logic controller for Creature Clicker UI
-- CREATES UI elements programmatically (no Rojo dependency)

print("[ClickerUILogic] ==========================================")
print("[ClickerUILogic] INITIALIZING - Creating UI from code")
print("[ClickerUILogic] ==========================================")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CREATE UI ELEMENTS PROGRAMMATICALLY
-- ============================================

print("[ClickerUILogic] Creating UI elements...")

-- Main ScreenGui
local mainUI = Instance.new("ScreenGui")
mainUI.Name = "CreatureClickerUI"
mainUI.ResetOnSpawn = false
mainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainUI.Parent = playerGui
print("[ClickerUILogic] ✓ ScreenGui created")

-- Coin Display Container (top-left)
local coinDisplay = Instance.new("Frame")
coinDisplay.Name = "CoinDisplay"
coinDisplay.Size = UDim2.new(0, 280, 0, 80)
coinDisplay.Position = UDim2.new(0, 20, 0, 20)
coinDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
coinDisplay.BackgroundTransparency = 0.2
coinDisplay.BorderSizePixel = 0
local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 12)
coinCorner.Parent = coinDisplay
coinDisplay.Parent = mainUI

-- Coin icon
local coinIcon = Instance.new("ImageLabel")
coinIcon.Name = "CoinIcon"
coinIcon.Size = UDim2.new(0, 50, 0, 50)
coinIcon.Position = UDim2.new(0, 15, 0.5, -25)
coinIcon.BackgroundTransparency = 1
coinIcon.Image = "rbxassetid://9083387555"
coinIcon.ImageColor3 = Color3.fromRGB(255, 215, 0)
coinIcon.Parent = coinDisplay

-- Coin counter text
local coinCounter = Instance.new("TextLabel")
coinCounter.Name = "CoinCount"
coinCounter.Size = UDim2.new(0, 200, 0, 50)
coinCounter.Position = UDim2.new(0, 70, 0.5, -25)
coinCounter.BackgroundTransparency = 1
coinCounter.Text = "0"
coinCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
coinCounter.TextSize = 36
coinCounter.Font = Enum.Font.GothamBold
coinCounter.TextXAlignment = Enum.TextXAlignment.Left
coinCounter.Parent = coinDisplay

-- Coins per second label
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Name = "CPS"
cpsLabel.Size = UDim2.new(0, 200, 0, 20)
cpsLabel.Position = UDim2.new(0, 70, 1, -22)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "0 coins/sec"
cpsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
cpsLabel.TextSize = 16
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Parent = coinDisplay

print("[ClickerUILogic] ✓ Coin display created")

-- Main Click Button (center-bottom)
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 250, 0, 250)
clickButton.Position = UDim2.new(0.5, -125, 0.5, -50)
clickButton.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
clickButton.BorderSizePixel = 0
cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(1, 0) -- Circle
cornerRadius.Parent = clickButton
cornerStroke = Instance.new("UIStroke")
cornerStroke.Color = Color3.fromRGB(96, 165, 250)
cornerStroke.Thickness = 4
cornerStroke.Parent = clickButton
gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 99, 235))
})
gradient.Parent = clickButton
clickButton.Text = "CLICK!"
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.TextSize = 36
clickButton.Font = Enum.Font.GothamBlack
clickButton.Parent = mainUI

-- Add shadow to button
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 0, 0, 8)
shadow.BackgroundColor3 = Color3.fromRGB(29, 78, 216)
shadow.BackgroundTransparency = 0.5
shadow.ZIndex = -1
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(1, 0)
shadowCorner.Parent = shadow
shadow.Parent = clickButton

print("[ClickerUILogic] ✓ Click button created")

-- Hatch Button (bottom-right)
local hatchButton = Instance.new("TextButton")
hatchButton.Name = "HatchButton"
hatchButton.Size = UDim2.new(0, 180, 0, 60)
hatchButton.Position = UDim2.new(1, -200, 1, -100)
hatchButton.BackgroundColor3 = Color3.fromRGB(139, 92, 246) -- Purple
hatchButton.BorderSizePixel = 0
local hatchCorner = Instance.new("UICorner")
hatchCorner.CornerRadius = UDim.new(0, 12)
hatchCorner.Parent = hatchButton
local hatchStroke = Instance.new("UIStroke")
hatchStroke.Color = Color3.fromRGB(167, 139, 250)
hatchStroke.Thickness = 3
hatchStroke.Parent = hatchButton
hatchButton.Text = "🥚 HATCH (100)"
hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hatchButton.TextSize = 22
hatchButton.Font = Enum.Font.GothamBold
hatchButton.Parent = mainUI

print("[ClickerUILogic] ✓ Hatch button created")

-- Settings Button (top-right)
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 50, 0, 50)
settingsButton.Position = UDim2.new(1, -70, 0, 20)
settingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
settingsButton.BorderSizePixel = 0
local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 10)
settingsCorner.Parent = settingsButton
settingsButton.Text = "⚙️"
settingsButton.TextSize = 28
settingsButton.Font = Enum.Font.GothamBold
settingsButton.Parent = mainUI

print("[ClickerUILogic] ✓ All UI elements created")

-- ============================================
-- REMOTE EVENTS
-- ============================================

local Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 10)
local ClickRequest = Remotes:WaitForChild("ClickRequest")
local ClickResponse = Remotes:WaitForChild("ClickResponse")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")

print("[ClickerUILogic] ✓ Remotes connected")

-- ============================================
-- STATE & CONFIG
-- ============================================

local currentCoins = 0
local displayedCoins = 0
local settings = { soundEnabled = true }

-- ============================================
-- SOUNDS
-- ============================================

local Sounds = {}
local function initSounds()
    local soundFolder = Instance.new("Folder")
    soundFolder.Name = "UISounds"
    soundFolder.Parent = playerGui
    
    Sounds.Coin = Instance.new("Sound")
    Sounds.Coin.SoundId = "rbxassetid://9113083740"
    Sounds.Coin.Volume = 0.6
    Sounds.Coin.Parent = soundFolder
    
    Sounds.Click = Instance.new("Sound")
    Sounds.Click.SoundId = "rbxassetid://9114488953"
    Sounds.Click.Volume = 0.4
    Sounds.Click.Parent = soundFolder
end

local function playSound(soundName)
    if settings.soundEnabled and Sounds[soundName] then
        Sounds[soundName]:Play()
    end
end

-- ============================================
-- ANIMATIONS
-- ============================================

local function animateButtonPress(button)
    local originalSize = button.Size
    TweenService:Create(button, TweenInfo.new(0.08), {
        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.92, 
                        originalSize.Y.Scale, originalSize.Y.Offset * 0.92)
    }):Play()
    
    task.delay(0.08, function()
        TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
    end)
end

local function playCoinEarnedAnimation(amount, position)
    local floatingText = Instance.new("TextLabel")
    floatingText.Size = UDim2.new(0, 150, 0, 50)
    floatingText.Position = UDim2.new(0, position.X - 75, 0, position.Y - 25)
    floatingText.BackgroundTransparency = 1
    floatingText.Text = "+" .. tostring(amount)
    floatingText.TextColor3 = Color3.fromRGB(255, 215, 0)
    floatingText.TextSize = 28
    floatingText.Font = Enum.Font.GothamBold
    floatingText.TextStrokeTransparency = 0.8
    floatingText.Parent = mainUI
    
    TweenService:Create(floatingText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, position.X - 75, 0, position.Y - 100),
        TextTransparency = 1,
        TextStrokeTransparency = 1
    }):Play()
    
    game:GetService("Debris"):AddItem(floatingText, 1)
    playSound("Coin")
end

-- ============================================
-- CLICK HANDLING
-- ============================================

local function onClick()
    if not ClickRequest then return end
    animateButtonPress(clickButton)
    playSound("Click")
    ClickRequest:FireServer()
end

-- Server response
ClickResponse.OnClientEvent:Connect(function(data)
    if data.success then
        currentCoins = data.totalCoins
        local mouse = player:GetMouse()
        playCoinEarnedAnimation(data.coinsEarned, Vector2.new(mouse.X, mouse.Y))
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================

print("[ClickerUILogic] Wiring up events...")

initSounds()

-- Connect click handler
if clickButton then
    clickButton.MouseButton1Click:Connect(onClick)
end

-- Hatch button handler (placeholder - fires same remote for now)
if hatchButton then
    hatchButton.MouseButton1Click:Connect(function()
        animateButtonPress(hatchButton)
        playSound("Click")
        -- TODO: Fire hatch remote when implemented
        print("[ClickerUILogic] Hatch requested (not yet implemented)")
    end)
end

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and clickButton then
        onClick()
    end
end)

-- Fetch initial data
if GetPlayerData then
    task.spawn(function()
        local success, data = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        if success and data then
            currentCoins = data.coins or 0
            displayedCoins = currentCoins
            if coinCounter then
                coinCounter.Text = tostring(currentCoins)
            end
        end
    end)
end

-- Smooth coin counter
RunService.RenderStepped:Connect(function()
    if coinCounter and math.abs(currentCoins - displayedCoins) > 0.5 then
        displayedCoins = displayedCoins + (currentCoins - displayedCoins) * 0.1
        coinCounter.Text = tostring(math.floor(displayedCoins))
    end
end)

print("[ClickerUILogic] ==========================================")
print("[ClickerUILogic] READY! UI created successfully")
print("[ClickerUILogic] ==========================================")
