-- ClickerUI.Client.lua
-- Main UI controller for Creature Clicker
-- Handles: Click button, coin display, pet display, animations, particles, sound

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvents (match server naming)
local Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 10)
if not Remotes then
	warn("[ClickerUI] CreatureClickerRemotes not found, waiting...")
	Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 30)
end

local ClickRequest = Remotes:WaitForChild("ClickRequest", 10)
local ClickResponse = Remotes:WaitForChild("ClickResponse", 10)
local GetPlayerData = Remotes:WaitForChild("GetPlayerData", 10)

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

-- Create Particle Effect
local function createParticles(position, color)
	if not settings.particlesEnabled then return end
	
	local particleFolder = Instance.new("Folder")
	particleFolder.Name = "Particles_" .. tick()
	particleFolder.Parent = playerGui
	
	for i = 1, CONFIG.PARTICLE_COUNT do
		local particle = Instance.new("Frame")
		particle.Name = "Particle"
		particle.Size = UDim2.new(0, math.random(4, 10), 0, math.random(4, 10))
		particle.Position = UDim2.new(0, position.X, 0, position.Y)
		particle.BackgroundColor3 = color or Color3.fromRGB(255, 215, 0)
		particle.BorderSizePixel = 0
		particle.BackgroundTransparency = 0
		particle.Parent = particleFolder
		
		-- Corner radius for circle particles
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = particle
		
		-- Random direction
		local angle = math.random() * math.pi * 2
		local distance = math.random(80, 150)
		local endX = position.X + math.cos(angle) * distance
		local endY = position.Y + math.sin(angle) * distance
		
		-- Tween out
		local tweenInfo = TweenInfo.new(
			math.random(30, 60) / 100,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		
		local tween = TweenService:Create(particle, tweenInfo, {
			Position = UDim2.new(0, endX, 0, endY),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0)
		})
		
		tween:Play()
		tween.Completed:Connect(function()
			particle:Destroy()
		end)
	end
	
	-- Cleanup
	delay(1, function()
		particleFolder:Destroy()
	end)
end

-- Click Feedback Popup (+X text)
local function createClickFeedback(amount, position)
	local feedback = Instance.new("TextLabel")
	feedback.Name = "ClickFeedback"
	feedback.Size = UDim2.new(0, 100, 0, 40)
	feedback.Position = UDim2.new(0, position.X - 50 + math.random(-20, 20), 0, position.Y - 50 + math.random(-10, 10))
	feedback.BackgroundTransparency = 1
	feedback.Text = "+" .. amount
	feedback.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
	feedback.TextScaled = true
	feedback.Font = Enum.Font.GothamBlack
	feedback.TextStrokeTransparency = 0.5
	feedback.TextStrokeColor3 = Color3.fromRGB(150, 100, 0)
	feedback.Parent = mainUI
	
	-- Float up and fade out tween
	local tweenInfo = TweenInfo.new(
		CONFIG.CLICK_FEEDBACK_DURATION,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	
	local tween = TweenService:Create(feedback, tweenInfo, {
		Position = UDim2.new(0, feedback.Position.X.Offset, 0, feedback.Position.Y.Offset - 60),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		feedback:Destroy()
	end)
end

-- Pet Idle Animation (bounce/pulse loop)
local function startIdleAnimation()
	if not petDisplay or not petDisplay.PetImage then return end
	
	-- Stop existing animation
	if idleTween then
		idleTween:Cancel()
		idleTween = nil
	end
	
	local petImage = petDisplay.PetImage
	local originalSize = UDim2.new(0, 50, 0, 50) -- Base size
	
	-- Scale up tween
	local scaleUpInfo = TweenInfo.new(
		CONFIG.IDLE_ANIMATION_TIME / 2,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut
	)
	
	local function animateIdle()
		local scaleUp = TweenService:Create(petImage, scaleUpInfo, {
			Size = UDim2.new(0, originalSize.X.Offset * CONFIG.IDLE_ANIMATION_SCALE, 0, originalSize.Y.Offset * CONFIG.IDLE_ANIMATION_SCALE)
		})
		
		local scaleDown = TweenService:Create(petImage, scaleUpInfo, {
			Size = originalSize
		})
		
		scaleUp:Play()
		scaleUp.Completed:Connect(function()
			if petImage and petImage.Parent then
				scaleDown:Play()
			end
		end)
		
		scaleDown.Completed:Connect(function()
			if petImage and petImage.Parent then
				delay(0.1, animateIdle) -- Small pause between cycles
			end
		end)
		
		idleTween = scaleUp
	end
	
	animateIdle()
end

local function stopIdleAnimation()
	if idleTween then
		idleTween:Cancel()
		idleTween = nil
	end
	if petDisplay and petDisplay.PetImage then
		petDisplay.PetImage.Size = UDim2.new(0, 50, 0, 50) -- Reset to original
	end
end

-- Update coins per second display
local function updateCoinsPerSecondDisplay()
	if not petDisplay or not petDisplay.CoinsPerSecondLabel then return end
	
	if currentCoinsPerSecond > 0 then
		petDisplay.CoinsPerSecondLabel.Text = "+" .. currentCoinsPerSecond .. "/sec"
		petDisplay.CoinsPerSecondLabel.Visible = true
	else
		petDisplay.CoinsPerSecondLabel.Visible = false
	end
end

-- Screen Shake Effect
local function screenShake(intensity)
	local camera = workspace.CurrentCamera
	local originalCFrame = camera.CFrame
	
	local shakeDuration = 0.3
	local elapsed = 0
	
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= shakeDuration then
			camera.CFrame = originalCFrame
			connection:Disconnect()
			return
		end
		
		local decay = 1 - (elapsed / shakeDuration)
		local offset = Vector3.new(
			(math.random() - 0.5) * intensity * decay,
			(math.random() - 0.5) * intensity * decay,
			0
		)
		camera.CFrame = originalCFrame * CFrame.new(offset)
	end)
end

-- Flying Coin Animation
local function createFlyingCoins(fromPosition, toPosition, amount)
	local coinCount = math.min(CONFIG.FLYING_COIN_COUNT, math.floor(amount / 10) + 1)
	
	for i = 1, coinCount do
		local coin = Instance.new("ImageLabel")
		coin.Name = "FlyingCoin"
		coin.Size = UDim2.new(0, 30, 0, 30)
		coin.Position = UDim2.new(0, fromPosition.X + math.random(-30, 30), 0, fromPosition.Y + math.random(-30, 30))
		coin.BackgroundTransparency = 1
		coin.Image = "rbxassetid://3926305904" -- Coin icon
		coin.ImageColor3 = Color3.fromRGB(255, 215, 0)
		coin.Parent = mainUI
		
		-- Delay each coin slightly
		delay((i - 1) * 0.05, function()
			local tweenInfo = TweenInfo.new(
				CONFIG.FLYING_COIN_DURATION,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.In
			)
			
			local tween = TweenService:Create(coin, tweenInfo, {
				Position = UDim2.new(0, toPosition.X, 0, toPosition.Y),
				Size = UDim2.new(0, 15, 0, 15),
				ImageTransparency = 0.5
			})
			
			tween:Play()
			tween.Completed:Connect(function()
				coin:Destroy()
				-- Pulse the coin counter when coins arrive
				local pulseTween = TweenService:Create(coinCounter, TweenInfo.new(0.1), {
					Size = UDim2.new(0, 210, 0, 55)
				})
				pulseTween:Play()
				pulseTween.Completed:Connect(function()
					TweenService:Create(coinCounter, TweenInfo.new(0.1), {
						Size = UDim2.new(0, 200, 0, 50)
					}):Play()
				end)
			end)
		end)
	end
end

-- Number Ticking Animation
local function animateNumberChange(newValue)
	local difference = newValue - displayedCoins
	local steps = math.min(20, math.abs(difference))
	local increment = difference / steps
	
	for i = 1, steps do
		delay(i * CONFIG.NUMBER_TICK_SPEED, function()
			displayedCoins = displayedCoins + increment
			if i == steps then
				displayedCoins = newValue
			end
			
			-- Format with commas
			local formatted = tostring(math.floor(displayedCoins)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
			coinCounter.CoinsLabel.Text = "💰 " .. formatted
		end)
	end
end

-- Pet Bounce Animation
local function bouncePet()
	if not petDisplay or not petDisplay.PetImage then return end
	
	local originalSize = petDisplay.PetImage.Size
	local bounceUp = TweenService:Create(petDisplay.PetImage, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(originalSize.X.Scale * CONFIG.PET_BOUNCE_SCALE, 0, originalSize.Y.Scale * CONFIG.PET_BOUNCE_SCALE, 0)
	})
	
	local bounceDown = TweenService:Create(petDisplay.PetImage, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = originalSize
	})
	
	bounceUp:Play()
	bounceUp.Completed:Connect(function()
		bounceDown:Play()
	end)
end

-- Handle Click
local function handleClick()
	-- Button press animation
	local originalSize = UDim2.new(0, CONFIG.CLICK_BUTTON_SIZE, 0, CONFIG.CLICK_BUTTON_SIZE)
	local pressSize = UDim2.new(0, CONFIG.CLICK_BUTTON_SIZE * 0.9, 0, CONFIG.CLICK_BUTTON_SIZE * 0.9)
	
	local pressTween = TweenService:Create(clickButton, TweenInfo.new(0.05), {
		Size = pressSize
	})
	local releaseTween = TweenService:Create(clickButton, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalSize
	})
	
	pressTween:Play()
	playSound("Click")
	
	-- Get button center for particles
	local buttonPos = clickButton.AbsolutePosition
	local buttonSize = clickButton.AbsoluteSize
	local centerX = buttonPos.X + buttonSize.X / 2
	local centerY = buttonPos.Y + buttonSize.Y / 2
	
	-- Create particles
	createParticles(Vector2.new(centerX, centerY), Color3.fromRGB(255, 215, 0))
	
	pressTween.Completed:Connect(function()
		releaseTween:Play()
	end)
	
	-- Call server
	if ClickRequest then
		ClickRequest:FireServer()
	else
		-- Mock response for testing
		print("[UI] ClickRequest not available, using mock")
		local mockCoins = math.random(5, 25)
		onCoinsEarned(mockCoins, Vector2.new(centerX, centerY))
	end
end

-- Handle coins earned (response from server)
function onCoinsEarned(amount, clickPosition)
	currentCoins = currentCoins + amount
	
	-- Play coin sound
	playSound("Coin")
	
	-- Show click feedback popup
	createClickFeedback(amount, clickPosition)
	
	-- Animate coin counter
	animateNumberChange(currentCoins)
	
	-- Flying coins animation
	local counterPos = coinCounter.AbsolutePosition
	local counterSize = coinCounter.AbsoluteSize
	local targetX = counterPos.X + counterSize.X / 2
	local targetY = counterPos.Y + counterSize.Y / 2
	
	createFlyingCoins(clickPosition, Vector2.new(targetX, targetY), amount)
	
	-- Screen shake for big earnings
	if amount >= CONFIG.SCREEN_SHAKE_THRESHOLD then
		screenShake(0.5)
	end
	
	-- Bounce pet
	bouncePet()
end

-- Update equipped pet display
function updateEquippedPet(petData)
	equippedPet = petData
	if not petData then
		petDisplay.PetImage.Image = ""
		petDisplay.MultiplierLabel.Text = "No Pet Equipped"
		petDisplay.NameLabel.Text = ""
		stopIdleAnimation()
		currentCoinsPerSecond = 0
		updateCoinsPerSecondDisplay()
		return
	end
	
	petDisplay.PetImage.Image = petData.imageId or "rbxassetid://3926305904"
	petDisplay.NameLabel.Text = petData.name or "Unknown Pet"
	petDisplay.MultiplierLabel.Text = "💎 " .. (petData.multiplier or 1) .. "x Coins"
	
	-- Color based on rarity
	local rarityColors = {
		Common = Color3.fromRGB(170, 170, 170),
		Uncommon = Color3.fromRGB(85, 255, 85),
		Rare = Color3.fromRGB(85, 165, 255),
		Epic = Color3.fromRGB(170, 85, 255),
		Legendary = Color3.fromRGB(255, 215, 0)
	}
	
	petDisplay.NameLabel.TextColor3 = rarityColors[petData.rarity] or Color3.fromRGB(255, 255, 255)
	
	-- Start idle animation
	startIdleAnimation()
	
	-- Fetch and display coins per second
	local GetCoinsPerSecond = Remotes:WaitForChild("GetCoinsPerSecond", 5)
	if GetCoinsPerSecond then
		local success, cps = pcall(function()
			return GetCoinsPerSecond:InvokeServer()
		end)
		if success and cps then
			currentCoinsPerSecond = cps
			updateCoinsPerSecondDisplay()
		end
	end
	
	playSound("Equip")
end

-- Create Main UI
local function createMainUI()
	-- ScreenGui
	mainUI = Instance.new("ScreenGui")
	mainUI.Name = "ClickerUI"
	mainUI.ResetOnSpawn = false
	mainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainUI.Parent = playerGui
	
	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = mainUI
	
	-- Coin Counter (Top Right)
	coinCounter = Instance.new("Frame")
	coinCounter.Name = "CoinCounter"
	coinCounter.Size = UDim2.new(0, 200, 0, 50)
	coinCounter.Position = UDim2.new(1, -220, 0, 20)
	coinCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	coinCounter.BackgroundTransparency = 0.2
	coinCounter.BorderSizePixel = 0
	coinCounter.Parent = mainFrame
	
	local coinCorner = Instance.new("UICorner")
	coinCorner.CornerRadius = UDim.new(0, 12)
	coinCorner.Parent = coinCounter
	
	local coinStroke = Instance.new("UIStroke")
	coinStroke.Color = Color3.fromRGB(255, 215, 0)
	coinStroke.Thickness = 2
	coinStroke.Parent = coinCounter
	
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(1, 0, 1, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "💰 0"
	coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	coinsLabel.TextScaled = true
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.Parent = coinCounter
	
	-- Pet Display (Top Left)
	petDisplay = Instance.new("Frame")
	petDisplay.Name = "PetDisplay"
	petDisplay.Size = UDim2.new(0, 180, 0, 70)
	petDisplay.Position = UDim2.new(0, 20, 0, 20)
	petDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	petDisplay.BackgroundTransparency = 0.2
	petDisplay.BorderSizePixel = 0
	petDisplay.Parent = mainFrame
	
	local petCorner = Instance.new("UICorner")
	petCorner.CornerRadius = UDim.new(0, 12)
	petCorner.Parent = petDisplay
	
	local petStroke = Instance.new("UIStroke")
	petStroke.Color = Color3.fromRGB(170, 85, 255)
	petStroke.Thickness = 2
	petStroke.Parent = petDisplay
	
	local petImage = Instance.new("ImageLabel")
	petImage.Name = "PetImage"
	petImage.Size = UDim2.new(0, 50, 0, 50)
	petImage.Position = UDim2.new(0, 10, 0.5, -25)
	petImage.BackgroundTransparency = 1
	petImage.Image = "rbxassetid://3926305904"
	petImage.Parent = petDisplay
	
	local petName = Instance.new("TextLabel")
	petName.Name = "NameLabel"
	petName.Size = UDim2.new(1, -75, 0, 25)
	petName.Position = UDim2.new(0, 70, 0, 10)
	petName.BackgroundTransparency = 1
	petName.Text = "No Pet"
	petName.TextColor3 = Color3.fromRGB(255, 255, 255)
	petName.TextScaled = true
	petName.Font = Enum.Font.GothamBold
	petName.TextXAlignment = Enum.TextXAlignment.Left
	petName.Parent = petDisplay
	
	local petMultiplier = Instance.new("TextLabel")
	petMultiplier.Name = "MultiplierLabel"
	petMultiplier.Size = UDim2.new(1, -75, 0, 20)
	petMultiplier.Position = UDim2.new(0, 70, 0, 40)
	petMultiplier.BackgroundTransparency = 1
	petMultiplier.Text = "Equip a pet!"
	petMultiplier.TextColor3 = Color3.fromRGB(255, 215, 0)
	petMultiplier.TextScaled = true
	petMultiplier.Font = Enum.Font.Gotham
	petMultiplier.TextXAlignment = Enum.TextXAlignment.Left
	petMultiplier.Parent = petDisplay
	
	-- Coins per second label (below pet image)
	local coinsPerSecondLabel = Instance.new("TextLabel")
	coinsPerSecondLabel.Name = "CoinsPerSecondLabel"
	coinsPerSecondLabel.Size = UDim2.new(1, -20, 0, 18)
	coinsPerSecondLabel.Position = UDim2.new(0, 10, 1, -25)
	coinsPerSecondLabel.BackgroundTransparency = 1
	coinsPerSecondLabel.Text = "+0/sec"
	coinsPerSecondLabel.TextColor3 = Color3.fromRGB(85, 255, 85)
	coinsPerSecondLabel.TextScaled = true
	coinsPerSecondLabel.Font = Enum.Font.GothamBold
	coinsPerSecondLabel.TextXAlignment = Enum.TextXAlignment.Center
	coinsPerSecondLabel.Visible = false
	coinsPerSecondLabel.Parent = petDisplay
	
	-- Click Button (Center)
	clickButton = Instance.new("ImageButton")
	clickButton.Name = "ClickButton"
	clickButton.Size = UDim2.new(0, CONFIG.CLICK_BUTTON_SIZE, 0, CONFIG.CLICK_BUTTON_SIZE)
	clickButton.Position = UDim2.new(0.5, -CONFIG.CLICK_BUTTON_SIZE/2, 0.5, -CONFIG.CLICK_BUTTON_SIZE/2)
	clickButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	clickButton.Image = "rbxassetid://3926305904" -- Circle shape
	clickButton.ImageColor3 = Color3.fromRGB(255, 215, 0)
	clickButton.Parent = mainFrame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(1, 0)
	buttonCorner.Parent = clickButton
	
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 200)
	buttonStroke.Thickness = 4
	buttonStroke.Parent = clickButton
	
	local buttonGradient = Instance.new("UIGradient")
	buttonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 100)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 0))
	})
	buttonGradient.Parent = clickButton
	
	-- Click text
	local clickText = Instance.new("TextLabel")
	clickText.Name = "ClickText"
	clickText.Size = UDim2.new(1, 0, 0.3, 0)
	clickText.Position = UDim2.new(0, 0, 0.35, 0)
	clickText.BackgroundTransparency = 1
	clickText.Text = "CLICK!"
	clickText.TextColor3 = Color3.fromRGB(80, 50, 0)
	clickText.TextScaled = true
	clickText.Font = Enum.Font.GothamBlack
	clickText.Parent = clickButton
	
	-- Button shadow
	local buttonShadow = Instance.new("ImageLabel")
	buttonShadow.Name = "Shadow"
	buttonShadow.Size = UDim2.new(1, 10, 1, 10)
	buttonShadow.Position = UDim2.new(0, -5, 0, -5)
	buttonShadow.BackgroundTransparency = 1
	buttonShadow.Image = "rbxassetid://3926305904"
	buttonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	buttonShadow.ImageTransparency = 0.6
	buttonShadow.ZIndex = -1
	buttonShadow.Parent = clickButton
	
	-- Hatch Button (Bottom Right)
	hatchButton = Instance.new("TextButton")
	hatchButton.Name = "HatchButton"
	hatchButton.Size = UDim2.new(0, 120, 0, 50)
	hatchButton.Position = UDim2.new(1, -140, 1, -70)
	hatchButton.BackgroundColor3 = Color3.fromRGB(170, 85, 255)
	hatchButton.Text = "🥚 HATCH"
	hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	hatchButton.TextScaled = true
	hatchButton.Font = Enum.Font.GothamBold
	hatchButton.Parent = mainFrame
	
	local hatchCorner = Instance.new("UICorner")
	hatchCorner.CornerRadius = UDim.new(0, 10)
	hatchCorner.Parent = hatchButton
	
	local hatchStroke = Instance.new("UIStroke")
	hatchStroke.Color = Color3.fromRGB(200, 150, 255)
	hatchStroke.Thickness = 2
	hatchStroke.Parent = hatchButton
	
	-- Settings Button (Bottom Left)
	settingsButton = Instance.new("ImageButton")
	settingsButton.Name = "SettingsButton"
	settingsButton.Size = UDim2.new(0, 50, 0, 50)
	settingsButton.Position = UDim2.new(0, 20, 1, -70)
	settingsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	settingsButton.Image = "rbxassetid://3926307971" -- Settings gear
	settingsButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
	settingsButton.Parent = mainFrame
	
	local settingsCorner = Instance.new("UICorner")
	settingsCorner.CornerRadius = UDim.new(1, 0)
	settingsCorner.Parent = settingsButton
	
	-- Input connections
	clickButton.MouseButton1Down:Connect(handleClick)
	
	-- Touch support for mobile
	clickButton.TouchTap:Connect(handleClick)
	
	-- Hatch button
	hatchButton.MouseButton1Click:Connect(function()
		playSound("Click")
		-- Open shop UI
		if _G.HatchShopUI then
			_G.HatchShopUI.open()
		else
			print("[UI] HatchShopUI not loaded yet")
		end
	end)
	
	-- Settings button
	settingsButton.MouseButton1Click:Connect(function()
		playSound("Click")
		toggleSettings()
	end)
end

-- Settings Menu
local settingsMenu = nil

function toggleSettings()
	if settingsMenu then
		settingsMenu:Destroy()
		settingsMenu = nil
		return
	end
	
	settingsMenu = Instance.new("Frame")
	settingsMenu.Name = "SettingsMenu"
	settingsMenu.Size = UDim2.new(0, 250, 0, 200)
	settingsMenu.Position = UDim2.new(0.5, -125, 0.5, -100)
	settingsMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	settingsMenu.BorderSizePixel = 0
	settingsMenu.Parent = mainUI
	
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 15)
	menuCorner.Parent = settingsMenu
	
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = Color3.fromRGB(100, 100, 100)
	menuStroke.Thickness = 2
	menuStroke.Parent = settingsMenu
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "SETTINGS"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = settingsMenu
	
	-- Sound toggle
	local soundToggle = createToggle("Sound Effects", settings.soundEnabled, UDim2.new(0, 20, 0, 60), function(enabled)
		settings.soundEnabled = enabled
	end)
	soundToggle.Parent = settingsMenu
	
	-- Particles toggle
	local particleToggle = createToggle("Particles", settings.particlesEnabled, UDim2.new(0, 20, 0, 110), function(enabled)
		settings.particlesEnabled = enabled
	end)
	particleToggle.Parent = settingsMenu
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 100, 0, 35)
	closeButton.Position = UDim2.new(0.5, -50, 1, -50)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = settingsMenu
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
	
	closeButton.MouseButton1Click:Connect(function()
		playSound("Click")
		toggleSettings()
	end)
end

function createToggle(labelText, defaultValue, position, callback)
	local toggle = Instance.new("Frame")
	toggle.Name = labelText .. "Toggle"
	toggle.Size = UDim2.new(1, -40, 0, 40)
	toggle.Position = position
	toggle.BackgroundTransparency = 1
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggle
	
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(0, 60, 0, 30)
	button.Position = UDim2.new(1, -70, 0.5, -15)
	button.BackgroundColor3 = defaultValue and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 80, 80)
	button.Text = defaultValue and "ON" or "OFF"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = toggle
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	
	local enabled = defaultValue
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.Text = enabled and "ON" or "OFF"
		button.BackgroundColor3 = enabled and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 80, 80)
		playSound("Click")
		callback(enabled)
	end)
	
	return toggle
end

-- Listen for server events
local function connectRemoteEvents()
	if ClickResponse then
		-- Listen for click responses from server
		ClickResponse.OnClientEvent:Connect(function(coinsEarned)
			local buttonPos = clickButton.AbsolutePosition
			local buttonSize = clickButton.AbsoluteSize
			onCoinsEarned(coinsEarned, Vector2.new(
				buttonPos.X + buttonSize.X / 2,
				buttonPos.Y + buttonSize.Y / 2
			))
		end)
	end
	
	-- Listen for passive income updates
	local PassiveIncomeEvent = Remotes:WaitForChild("PassiveIncome", 5)
	if PassiveIncomeEvent then
		PassiveIncomeEvent.OnClientEvent:Connect(function(amount)
			currentCoins = currentCoins + amount
			animateNumberChange(currentCoins)
			bouncePet()
			playSound("Coin")
		end)
	end
	
	-- Listen for pet equipped updates
	local PetEquippedEvent = Remotes:WaitForChild("PetEquipped", 5)
	if PetEquippedEvent then
		PetEquippedEvent.OnClientEvent:Connect(function(petData)
			updateEquippedPet(petData)
		end)
	end
end

-- Initialize
local function init()
	print("[ClickerUI] Initializing...")
	
	initSounds()
	createMainUI()
	connectRemoteEvents()
	
	-- Request initial data
	if GetPlayerData then
		local success, data = pcall(function()
			return GetPlayerData:InvokeServer()
		end)
		
		if success and data then
			currentCoins = data.coins or 0
			displayedCoins = currentCoins
			
			-- Format with commas
			local formatted = tostring(currentCoins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
			coinCounter.CoinsLabel.Text = "💰 " .. formatted
			
			if data.equipped then
				updateEquippedPet(data.equipped)
			end
		end
	else
		-- Mock data for testing
		print("[UI] GetPlayerData not available, using mock data")
		currentCoins = 0
		displayedCoins = 0
	end
	
	print("[ClickerUI] Initialized successfully!")
end

-- Start
init()

-- Refresh pet data (called after hatch)
local function refreshPetData()
	local GetPlayerData = Remotes:WaitForChild("GetPlayerData", 5)
	if GetPlayerData then
		local success, data = pcall(function()
			return GetPlayerData:InvokeServer()
		end)
		if success and data then
			currentCoins = data.coins or currentCoins
			animateNumberChange(currentCoins)
			if data.equipped then
				updateEquippedPet(data.equipped)
			end
		end
	end
end

-- Expose functions for other scripts
_G.ClickerUI = {
	onCoinsEarned = onCoinsEarned,
	updateEquippedPet = updateEquippedPet,
	getSettings = function() return settings end,
	refreshPetData = refreshPetData
}