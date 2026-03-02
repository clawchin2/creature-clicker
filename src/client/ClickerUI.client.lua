-- ClickerUILogic.client.lua
-- Logic controller for Creature Clicker UI
-- UI elements are pre-built in StarterGui via Rojo - this script just wires them up

print("[ClickerUILogic] ==========================================")
print("[ClickerUILogic] INITIALIZING")
print("[ClickerUILogic] ==========================================")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- FIND PRE-BUILT UI (Created by Rojo in StarterGui)
-- ============================================

print("[ClickerUILogic] Finding UI elements...")

-- Wait for the ScreenGui to exist (should be immediate from StarterGui)
local mainUI = playerGui:WaitForChild("CreatureClickerUI", 10)
if not mainUI then
	error("[ClickerUILogic] CRITICAL: CreatureClickerUI ScreenGui not found in PlayerGui!")
	return
end
print("[ClickerUILogic] ✓ ScreenGui found")

-- Find UI elements by name
local coinDisplay = mainUI:WaitForChild("CoinDisplay", 5)
local coinCounter = coinDisplay and coinDisplay:WaitForChild("CoinCount", 2)
local cpsLabel = coinDisplay and coinDisplay:WaitForChild("CPS", 2)
local clickButton = mainUI:WaitForChild("ClickButton", 5)
local hatchButton = mainUI:WaitForChild("HatchButton", 5)
local settingsButton = mainUI:WaitForChild("SettingsButton", 5)

if not coinDisplay then warn("[ClickerUILogic] CoinDisplay not found") end
if not coinCounter then warn("[ClickerUILogic] CoinCount not found") end
if not clickButton then warn("[ClickerUILogic] ClickButton not found") end

print("[ClickerUILogic] ✓ All UI elements located")

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
print("[ClickerUILogic] READY!")
print("[ClickerUILogic] ==========================================")
