--[[
    ClickerUI.lua - Client-side UI for Creature Clicker
    Place in StarterPlayerScripts
    
    DEBUG VERSION: Includes verbose logging and safety checks
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

print("[ClickerUI] Initializing...")

local player = Players.LocalPlayer
if not player then
    warn("[ClickerUI] ERROR: LocalPlayer not found!")
    return
end
print("[ClickerUI] LocalPlayer found:", player.Name)

-- Wait for PlayerGui with timeout
local playerGui = player:WaitForChild("PlayerGui", 30)
if not playerGui then
    warn("[ClickerUI] ERROR: PlayerGui not found after 30s!")
    return
end
print("[ClickerUI] PlayerGui found")

-- Wait for remotes with timeout and fallback
print("[ClickerUI] Looking for CreatureClickerRemotes...")
local Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 30)

if not Remotes then
    warn("[ClickerUI] CreatureClickerRemotes not found! Waiting indefinitely...")
    Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes")
end
print("[ClickerUI] Found CreatureClickerRemotes")

-- Get remote events/functions
local ClickCreature = Remotes:WaitForChild("ClickCreature")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")
local BuyEgg = Remotes:WaitForChild("BuyEgg")
local EquipPet = Remotes:WaitForChild("EquipPet")
local UnequipPet = Remotes:WaitForChild("UnequipPet")
local GetCreatures = Remotes:WaitForChild("GetCreatures")
local GetCreatureConfig = Remotes:WaitForChild("GetCreatureConfig")

print("[ClickerUI] All remotes connected")

-- ============================================
-- UI CREATION
-- ============================================

-- Create main ScreenGui
local mainUI = Instance.new("ScreenGui")
mainUI.Name = "CreatureClickerUI"
mainUI.ResetOnSpawn = false
mainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainUI.Parent = playerGui
print("[ClickerUI] ScreenGui created")

-- Create fallback/error UI container
local fallbackFrame = Instance.new("Frame")
fallbackFrame.Name = "FallbackUI"
fallbackFrame.Size = UDim2.new(0, 400, 0, 200)
fallbackFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
fallbackFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
fallbackFrame.BorderSizePixel = 0
fallbackFrame.Visible = false
fallbackFrame.Parent = mainUI

local fallbackCorner = Instance.new("UICorner")
fallbackCorner.CornerRadius = UDim.new(0, 12)
fallbackCorner.Parent = fallbackFrame

local fallbackTitle = Instance.new("TextLabel")
fallbackTitle.Name = "Title"
fallbackTitle.Size = UDim2.new(1, 0, 0, 50)
fallbackTitle.BackgroundTransparency = 1
fallbackTitle.Text = "Connecting to Server..."
fallbackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
fallbackTitle.TextSize = 24
fallbackTitle.Font = Enum.Font.GothamBold
fallbackTitle.Parent = fallbackFrame

local fallbackText = Instance.new("TextLabel")
fallbackText.Name = "Message"
fallbackText.Size = UDim2.new(1, -40, 0, 60)
fallbackText.Position = UDim2.new(0, 20, 0, 70)
fallbackText.BackgroundTransparency = 1
fallbackText.Text = "Please wait while we connect to the game server."
fallbackText.TextColor3 = Color3.fromRGB(200, 200, 200)
fallbackText.TextSize = 18
fallbackText.Font = Enum.Font.Gotham
fallbackText.TextWrapped = true
fallbackText.Parent = fallbackFrame

-- Show fallback if remotes weren't found initially
if not Remotes then
    fallbackFrame.Visible = true
    print("[ClickerUI] Showing fallback UI - waiting for server")
end

-- Coin Display Frame
local coinFrame = Instance.new("Frame")
coinFrame.Name = "CoinDisplay"
coinFrame.Size = UDim2.new(0, 250, 0, 60)
coinFrame.Position = UDim2.new(0, 20, 0, 20)
coinFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
coinFrame.BorderSizePixel = 0
coinFrame.Parent = mainUI

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 8)
coinCorner.Parent = coinFrame

local coinIcon = Instance.new("ImageLabel")
coinIcon.Name = "Icon"
coinIcon.Size = UDim2.new(0, 40, 0, 40)
coinIcon.Position = UDim2.new(0, 10, 0.5, -20)
coinIcon.BackgroundTransparency = 1
coinIcon.Image = "rbxassetid://9321467643" -- Coin icon
coinIcon.Parent = coinFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinCount"
coinLabel.Size = UDim2.new(1, -60, 1, 0)
coinLabel.Position = UDim2.new(0, 60, 0, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "0"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 28
coinLabel.Font = Enum.Font.GothamBold
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = coinFrame

-- CPS Display
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Name = "CPS"
cpsLabel.Size = UDim2.new(1, -60, 0, 20)
cpsLabel.Position = UDim2.new(0, 60, 0.6, 0)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "0 coins/sec"
cpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
cpsLabel.TextSize = 14
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Parent = coinFrame

-- Click Button (Main)
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 200, 0, 200)
clickButton.Position = UDim2.new(0.5, -100, 0.6, -100)
clickButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
clickButton.Text = "CLICK!"
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.TextSize = 32
clickButton.Font = Enum.Font.GothamBlack
clickButton.Parent = mainUI

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0.5, 0) -- Circle
buttonCorner.Parent = clickButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(100, 160, 240)
buttonStroke.Thickness = 4
buttonStroke.Parent = clickButton

print("[ClickerUI] Click button created")

-- Click Animation Frame
local clickAnimFrame = Instance.new("Frame")
clickAnimFrame.Name = "ClickAnimation"
clickAnimFrame.Size = UDim2.new(0, 100, 0, 100)
clickAnimFrame.BackgroundTransparency = 1
clickAnimFrame.Parent = mainUI

-- Multiplier Display
local multiplierFrame = Instance.new("Frame")
multiplierFrame.Name = "MultiplierDisplay"
multiplierFrame.Size = UDim2.new(0, 150, 0, 40)
multiplierFrame.Position = UDim2.new(0.5, -75, 0.6, 120)
multiplierFrame.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
multiplierFrame.BorderSizePixel = 0
multiplierFrame.Visible = false
multiplierFrame.Parent = mainUI

local multiplierCorner = Instance.new("UICorner")
multiplierCorner.CornerRadius = UDim.new(0, 6)
multiplierCorner.Parent = multiplierFrame

local multiplierLabel = Instance.new("TextLabel")
multiplierLabel.Name = "Value"
multiplierLabel.Size = UDim2.new(1, 0, 1, 0)
multiplierLabel.BackgroundTransparency = 1
multiplierLabel.Text = "x1"
multiplierLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
multiplierLabel.TextSize = 20
multiplierLabel.Font = Enum.Font.GothamBold
multiplierLabel.Parent = multiplierFrame

-- Hatch/Egg Button
local hatchButton = Instance.new("TextButton")
local hatchCorner
hatchButton.Name = "HatchButton"
hatchButton.Size = UDim2.new(0, 120, 0, 50)
hatchButton.Position = UDim2.new(1, -140, 0, 20)
hatchButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
hatchButton.Text = "🥚 Hatch"
hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hatchButton.TextSize = 20
hatchButton.Font = Enum.Font.GothamBold
hatchButton.Parent = mainUI
hatchCorner = Instance.new("UICorner")
hatchCorner.CornerRadius = UDim.new(0, 8)
hatchCorner.Parent = hatchButton

-- Stats Button
local statsButton = Instance.new("TextButton")
statsButton.Name = "StatsButton"
statsButton.Size = UDim2.new(0, 120, 0, 50)
statsButton.Position = UDim2.new(1, -140, 0, 80)
statsButton.BackgroundColor3 = Color3.fromRGB(40, 80, 100)
statsButton.Text = "📊 Stats"
statsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
statsButton.TextSize = 20
statsButton.Font = Enum.Font.GothamBold
statsButton.Parent = mainUI

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsButton

-- Inventory Button
local invButton = Instance.new("TextButton")
invButton.Name = "InventoryButton"
invButton.Size = UDim2.new(0, 120, 0, 50)
invButton.Position = UDim2.new(1, -140, 0, 140)
invButton.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
invButton.Text = "🎒 Pets"
invButton.TextColor3 = Color3.fromRGB(255, 255, 255)
invButton.TextSize = 20
invButton.Font = Enum.Font.GothamBold
invButton.Parent = mainUI

local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = invButton

print("[ClickerUI] All UI elements created")

-- ============================================
-- STATE & DATA
-- ============================================

local playerData = {
    coins = 0,
    pets = {},
    equipped = nil,
    rebirths = 0
}

local creatureConfig = nil

-- ============================================
-- FUNCTIONS
-- ============================================

-- Format number with commas
local function formatNumber(num)
    if num >= 1000000000 then
        return string.format("%.2fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.2fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(math.floor(num))
end

-- Update coin display
local function updateCoinDisplay()
    coinLabel.Text = formatNumber(playerData.coins)
end

-- Play click animation
local function playClickAnimation(position)
    local anim = Instance.new("TextLabel")
    anim.Size = UDim2.new(0, 80, 0, 40)
    anim.Position = UDim2.new(0, position.X - 40, 0, position.Y - 20)
    anim.BackgroundTransparency = 1
    anim.Text = "+" .. formatNumber(1) -- Will be updated with actual value
    anim.TextColor3 = Color3.fromRGB(255, 215, 0)
    anim.TextSize = 24
    anim.Font = Enum.Font.GothamBold
    anim.Parent = clickAnimFrame
    
    -- Animate up and fade
    local tween = TweenService:Create(anim, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, position.X - 40, 0, position.Y - 80),
        TextTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        anim:Destroy()
    end)
end

-- Button press animation
local function buttonPressAnimation(button)
    local originalSize = button.Size
    local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, 
                        originalSize.Y.Scale, originalSize.Y.Offset * 0.95)
    })
    tween:Play()
    
    task.delay(0.1, function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = originalSize
        }):Play()
    end)
end

-- Fetch player data
local function fetchPlayerData()
    local success, data = pcall(function()
        return GetPlayerData:InvokeServer()
    end)
    
    if success and data then
        playerData = data
        updateCoinDisplay()
        print("[ClickerUI] Player data fetched successfully")
    else
        warn("[ClickerUI] Failed to fetch player data:", tostring(data))
    end
end

-- Fetch creature config
local function fetchCreatureConfig()
    local success, config = pcall(function()
        return GetCreatureConfig:InvokeServer()
    end)
    
    if success and config then
        creatureConfig = config
        print("[ClickerUI] Creature config fetched successfully")
    else
        warn("[ClickerUI] Failed to fetch creature config:", tostring(config))
    end
end

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Click handler
clickButton.MouseButton1Click:Connect(function()
    buttonPressAnimation(clickButton)
    
    local mouse = player:GetMouse()
    playClickAnimation(Vector2.new(mouse.X, mouse.Y))
    
    -- Send click to server
    local success, result = pcall(function()
        return ClickCreature:InvokeServer()
    end)
    
    if success and result then
        playerData.coins = result.coins or playerData.coins
        updateCoinDisplay()
        
        -- Show multiplier if applicable
        if result.multiplier and result.multiplier > 1 then
            multiplierLabel.Text = "x" .. result.multiplier .. " CRITICAL!"
            multiplierFrame.Visible = true
            task.delay(1, function()
                multiplierFrame.Visible = false
            end)
        end
    else
        warn("[ClickerUI] Click failed:", tostring(result))
    end
end)

-- Hatch button
hatchButton.MouseButton1Click:Connect(function()
    buttonPressAnimation(hatchButton)
    print("[ClickerUI] Hatch button clicked - not yet implemented")
    -- TODO: Open hatch menu
end)

-- Stats button
statsButton.MouseButton1Click:Connect(function()
    buttonPressAnimation(statsButton)
    print("[ClickerUI] Stats button clicked - not yet implemented")
    -- TODO: Open stats menu
end)

-- Inventory button
invButton.MouseButton1Click:Connect(function()
    buttonPressAnimation(invButton)
    print("[ClickerUI] Inventory button clicked - not yet implemented")
    -- TODO: Open inventory menu
end)

-- Keyboard shortcut (spacebar)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        clickButton:Activate()
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================

print("[ClickerUI] Setting up event handlers...")

-- Initial data fetch
fetchCreatureConfig()
fetchPlayerData()

-- Hide fallback UI if it was shown
if fallbackFrame.Visible then
    fallbackFrame.Visible = false
    print("[ClickerUI] Fallback UI hidden - server connection established")
end

print("[ClickerUI] Initialized successfully!")

-- Periodic data refresh
task.spawn(function()
    while true do
        task.wait(5)
        fetchPlayerData()
    end
end)

return mainUI
