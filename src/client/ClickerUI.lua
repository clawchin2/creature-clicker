-- DEBUG: File loaded check - MUST be at very top
print("[ClickerUI] ==========================================")
print("[ClickerUI] FILE LOADED - Start of execution")
print("[ClickerUI] ==========================================")

-- ClickerUI.Client.lua
-- Main UI controller for Creature Clicker
-- Handles: Click button, coin display, pet display, animations, particles, sound

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("[ClickerUI] Services acquired")

local player = Players.LocalPlayer
if not player then
	warn("[ClickerUI] CRITICAL: LocalPlayer is nil!")
	return
end
print("[ClickerUI] LocalPlayer:", player.Name)

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("[ClickerUI] CRITICAL: PlayerGui not found after 10s!")
	return
end
print("[ClickerUI] PlayerGui acquired")

-- RemoteEvents (match server naming)
print("[ClickerUI] Looking for CreatureClickerRemotes...")
local Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 10)
if not Remotes then
	warn("[ClickerUI] CreatureClickerRemotes not found after 10s!")
	-- Create a visible error UI
	local errorUI = Instance.new("ScreenGui")
	errorUI.Name = "ClickerUI_Error"
	errorUI.Parent = playerGui
	
	local errorFrame = Instance.new("Frame")
	errorFrame.Size = UDim2.new(0, 400, 0, 200)
	errorFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
	errorFrame.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
	errorFrame.Parent = errorUI
	
	local errorCorner = Instance.new("UICorner")
	errorCorner.CornerRadius = UDim.new(0, 12)
	errorCorner.Parent = errorFrame
	
	local errorTitle = Instance.new("TextLabel")
	errorTitle.Size = UDim2.new(1, 0, 0, 50)
	errorTitle.BackgroundTransparency = 1
	errorTitle.Text = "UI Error"
	errorTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
	errorTitle.TextSize = 28
	errorTitle.Font = Enum.Font.GothamBold
	errorTitle.Parent = errorFrame
	
	local errorText = Instance.new("TextLabel")
	errorText.Size = UDim2.new(1, -40, 0, 100)
	errorText.Position = UDim2.new(0, 20, 0, 60)
	errorText.BackgroundTransparency = 1
	errorText.Text = "Could not connect to game server.\n\nPlease rejoin the game."
	errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
	errorText.TextSize = 18
	errorText.Font = Enum.Font.Gotham
	errorText.TextWrapped = true
	errorText.Parent = errorFrame
	
	return
end
print("[ClickerUI] CreatureClickerRemotes folder found")

-- Get remote events with error handling
local ClickRequest = Remotes:WaitForChild("ClickRequest", 5)
local ClickResponse = Remotes:WaitForChild("ClickResponse", 5)
local GetPlayerData = Remotes:WaitForChild("GetPlayerData", 5)

if not ClickRequest then
	warn("[ClickerUI] ClickRequest remote not found!")
end
if not ClickResponse then
	warn("[ClickerUI] ClickResponse remote not found!")
end
if not GetPlayerData then
	warn("[ClickerUI] GetPlayerData remote not found!")
end

if not (ClickRequest and ClickResponse and GetPlayerData) then
	warn("[ClickerUI] Some remotes missing - UI will have limited functionality")
end

print("[ClickerUI] Remotes connected")

-- UI References
local mainUI = nil
local clickButton = nil
local coinCounter = nil
local petDisplay = nil
local hatchButton = nil
local settingsButton = nil

-- State
local currentCoins = 0
local displayedCoins = 0
local equippedPet = nil
local currentCoinsPerSecond = 0
local idleTween = nil
local settings = {
	soundEnabled = true,
	particlesEnabled = true
}

-- Configuration
local CONFIG = {
	CLICK_BUTTON_SIZE = 200,
	COIN_ANIMATION_SPEED = 0.3,
	NUMBER_TICK_SPEED = 0.05,
	PET_BOUNCE_SCALE = 1.15,
	SCREEN_SHAKE_THRESHOLD = 100, -- coins earned to trigger screen shake
	FLYING_COIN_COUNT = 5,
	FLYING_COIN_DURATION = 0.6,
	PARTICLE_COUNT = 12,
	CLICK_FEEDBACK_DURATION = 0.5,
	IDLE_ANIMATION_SCALE = 1.05,
	IDLE_ANIMATION_TIME = 2
}

-- Sound Effects (using Roblox default sounds for now)
local Sounds = {
	Click = nil,
	Coin = nil,
	Equip = nil
}

-- Initialize sound effects
local function initSounds()
	local soundFolder = Instance.new("Folder")
	soundFolder.Name = "UISounds"
	soundFolder.Parent = playerGui
	
	-- Coin sound (cha-ching style)
	Sounds.Coin = Instance.new("Sound")
	Sounds.Coin.Name = "CoinSound"
	Sounds.Coin.SoundId = "rbxassetid://9113083740" -- Satisfying coin sound
	Sounds.Coin.Volume = 0.6
	Sounds.Coin.Parent = soundFolder
	
	-- Click sound
	Sounds.Click = Instance.new("Sound")
	Sounds.Click.Name = "ClickSound"
	Sounds.Click.SoundId = "rbxassetid://9114488953" -- Pop click
	Sounds.Click.Volume = 0.4
	Sounds.Click.Parent = soundFolder
	
	-- Equip sound
	Sounds.Equip = Instance.new("Sound")
	Sounds.Equip.Name = "EquipSound"
	Sounds.Equip.SoundId = "rbxassetid://9114483740" -- Magic sparkle
	Sounds.Equip.Volume = 0.5
	Sounds.Equip.Parent = soundFolder
end

local function playSound(soundName)
	if not settings.soundEnabled then return end
	local sound = Sounds[soundName]
	if sound then
		sound:Play()
	end
end

-- ============================================
-- UI CREATION
-- ============================================

local function createMainUI()
	print("[ClickerUI] Creating main UI...")
	
	-- Main ScreenGui
	mainUI = Instance.new("ScreenGui")
	mainUI.Name = "CreatureClickerUI"
	mainUI.ResetOnSpawn = false
	mainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainUI.Parent = playerGui
	print("[ClickerUI] ScreenGui created")
	
	-- Coin Display (Top Left)
	local coinFrame = Instance.new("Frame")
	coinFrame.Name = "CoinDisplay"
	coinFrame.Size = UDim2.new(0, 280, 0, 70)
	coinFrame.Position = UDim2.new(0, 20, 0, 20)
	coinFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	coinFrame.BorderSizePixel = 0
	coinFrame.Parent = mainUI
	
	local coinCorner = Instance.new("UICorner")
	coinCorner.CornerRadius = UDim.new(0, 12)
	coinCorner.Parent = coinFrame
	
	local coinStroke = Instance.new("UIStroke")
	coinStroke.Color = Color3.fromRGB(255, 215, 0)
	coinStroke.Thickness = 2
	coinStroke.Parent = coinFrame
	
	local coinIcon = Instance.new("ImageLabel")
	coinIcon.Name = "Icon"
	coinIcon.Size = UDim2.new(0, 50, 0, 50)
	coinIcon.Position = UDim2.new(0, 10, 0.5, -25)
	coinIcon.BackgroundTransparency = 1
	coinIcon.Image = "rbxassetid://9321467643" -- Coin icon
	coinIcon.Parent = coinFrame
	
	coinCounter = Instance.new("TextLabel")
	coinCounter.Name = "CoinCount"
	coinCounter.Size = UDim2.new(1, -70, 0.6, 0)
	coinCounter.Position = UDim2.new(0, 70, 0, 5)
	coinCounter.BackgroundTransparency = 1
	coinCounter.Text = "0"
	coinCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinCounter.TextSize = 36
	coinCounter.Font = Enum.Font.GothamBold
	coinCounter.TextXAlignment = Enum.TextXAlignment.Left
	coinCounter.Parent = coinFrame
	
	local cpsLabel = Instance.new("TextLabel")
	cpsLabel.Name = "CPS"
	cpsLabel.Size = UDim2.new(1, -70, 0.4, 0)
	cpsLabel.Position = UDim2.new(0, 70, 0.6, 0)
	cpsLabel.BackgroundTransparency = 1
	cpsLabel.Text = "0 coins/sec"
	cpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	cpsLabel.TextSize = 16
	cpsLabel.Font = Enum.Font.Gotham
	cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	cpsLabel.Parent = coinFrame
	
	-- Main Click Button (Center)
	clickButton = Instance.new("TextButton")
	clickButton.Name = "ClickButton"
	clickButton.Size = UDim2.new(0, CONFIG.CLICK_BUTTON_SIZE, 0, CONFIG.CLICK_BUTTON_SIZE)
	clickButton.Position = UDim2.new(0.5, -CONFIG.CLICK_BUTTON_SIZE/2, 0.6, -CONFIG.CLICK_BUTTON_SIZE/2)
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
	
	local buttonGradient = Instance.new("UIGradient")
	buttonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 180))
	})
	buttonGradient.Parent = clickButton
	
	print("[ClickerUI] Click button created")
	
	-- Hatch Button (Top Right)
	hatchButton = Instance.new("TextButton")
	hatchButton.Name = "HatchButton"
	hatchButton.Size = UDim2.new(0, 140, 0, 55)
	hatchButton.Position = UDim2.new(1, -160, 0, 20)
	hatchButton.BackgroundColor3 = Color3.fromRGB(100, 60, 140)
	hatchButton.Text = "🥚 Hatch Egg"
	hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	hatchButton.TextSize = 20
	hatchButton.Font = Enum.Font.GothamBold
	hatchButton.Parent = mainUI
	
	local hatchCorner = Instance.new("UICorner")
	hatchCorner.CornerRadius = UDim.new(0, 10)
	hatchCorner.Parent = hatchButton
	
	local hatchStroke = Instance.new("UIStroke")
	hatchStroke.Color = Color3.fromRGB(140, 100, 180)
	hatchStroke.Thickness = 2
	hatchStroke.Parent = hatchButton
	
	-- Settings Button (Bottom Right)
	settingsButton = Instance.new("TextButton")
	settingsButton.Name = "SettingsButton"
	settingsButton.Size = UDim2.new(0, 50, 0, 50)
	settingsButton.Position = UDim2.new(1, -70, 1, -70)
	settingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	settingsButton.Text = "⚙️"
	settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	settingsButton.TextSize = 24
	settingsButton.Font = Enum.Font.GothamBold
	settingsButton.Parent = mainUI
	
	local settingsCorner = Instance.new("UICorner")
	settingsCorner.CornerRadius = UDim.new(0, 10)
	settingsCorner.Parent = settingsButton
	
	print("[ClickerUI] All UI elements created")
	
	return {
		mainUI = mainUI,
		clickButton = clickButton,
		coinCounter = coinCounter,
		hatchButton = hatchButton,
		settingsButton = settingsButton,
		cpsLabel = cpsLabel
	}
end

-- ============================================
-- ANIMATION FUNCTIONS
-- ============================================

local function animateButtonPress(button)
	local originalSize = button.Size
	local tween = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
		Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.92, 
		                originalSize.Y.Scale, originalSize.Y.Offset * 0.92)
	})
	tween:Play()
	
	task.delay(0.08, function()
		TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
	end)
end

local function playCoinEarnedAnimation(amount, position)
	-- Create floating text
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
	
	-- Animate up and fade
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
	if not ClickRequest then
		warn("[ClickerUI] Cannot click - ClickRequest remote not available")
		return
	end
	
	animateButtonPress(clickButton)
	playSound("Click")
	
	-- Send click to server
	ClickRequest:FireServer()
end

-- Listen for server response
if ClickResponse then
	ClickResponse.OnClientEvent:Connect(function(data)
		if data.success then
			currentCoins = data.totalCoins
			
			-- Get mouse position for animation
			local mouse = player:GetMouse()
			playCoinEarnedAnimation(data.coinsEarned, Vector2.new(mouse.X, mouse.Y))
		else
			warn("[ClickerUI] Click failed:", data.error)
		end
	end)
end

-- ============================================
-- INITIALIZATION
-- ============================================

print("[ClickerUI] Starting initialization...")

-- Initialize sounds
initSounds()

-- Create UI
local uiElements = createMainUI()

-- Connect click handler
clickButton.MouseButton1Click:Connect(onClick)

-- Keyboard shortcut (spacebar)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		onClick()
	end
end)

-- Fetch initial player data
if GetPlayerData then
	print("[ClickerUI] Fetching initial player data...")
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
			print("[ClickerUI] Initial data loaded - Coins:", currentCoins)
		else
			warn("[ClickerUI] Failed to fetch initial data:", tostring(data))
		end
	end)
else
	warn("[ClickerUI] Cannot fetch initial data - GetPlayerData remote not available")
end

-- Number tick animation (smooth coin counter)
RunService.RenderStepped:Connect(function()
	if math.abs(currentCoins - displayedCoins) > 0.5 then
		displayedCoins = displayedCoins + (currentCoins - displayedCoins) * 0.1
		if coinCounter then
			coinCounter.Text = tostring(math.floor(displayedCoins))
		end
	end
end)

print("[ClickerUI] ==========================================")
print("[ClickerUI] INITIALIZED SUCCESSFULLY!")
print("[ClickerUI] ==========================================")
