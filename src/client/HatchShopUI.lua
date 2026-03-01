-- HatchShopUI.lua
-- Egg shop and hatching animation UI
-- Client-side only - calls server for purchases

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes (match server naming)
local Remotes = ReplicatedStorage:WaitForChild("CreatureClickerRemotes", 10)
local HatchRequest = Remotes:WaitForChild("HatchRequest", 10)
local HatchResult = Remotes:WaitForChild("HatchResult", 10)
local GetPlayerData = Remotes:WaitForChild("GetPlayerData", 10)

-- UI State
local shopUI = nil
local isHatching = false

-- Egg definitions (matches server CreatureConfig.Eggs)
local EGGS = {
	{
		id = "basic_egg",
		name = "Basic Egg",
		price = 100,
		color = Color3.fromRGB(200, 200, 200),
		description = "Common creatures inside!",
		rarities = {Common = 70, Uncommon = 25, Rare = 5}
	},
	{
		id = "fire_egg",
		name = "Fire Egg",
		price = 250,
		color = Color3.fromRGB(255, 100, 50),
		description = "Fire element creatures!",
		rarities = {Common = 50, Uncommon = 35, Rare = 12, Epic = 3}
	},
	{
		id = "water_egg",
		name = "Water Egg",
		price = 250,
		color = Color3.fromRGB(50, 150, 255),
		description = "Water element creatures!",
		rarities = {Common = 50, Uncommon = 35, Rare = 12, Epic = 3}
	},
	{
		id = "earth_egg",
		name = "Earth Egg",
		price = 250,
		color = Color3.fromRGB(100, 255, 100),
		description = "Earth element creatures!",
		rarities = {Common = 50, Uncommon = 35, Rare = 12, Epic = 3}
	},
	{
		id = "void_egg",
		name = "Void Egg",
		price = 500,
		color = Color3.fromRGB(170, 85, 255),
		description = "Higher chance for rare creatures!",
		rarities = {Common = 50, Uncommon = 30, Rare = 20, Epic = 8, Legendary = 2}
	}
}

-- Sound Effects
local Sounds = {}

local function initSounds()
	local soundFolder = Instance.new("Folder")
	soundFolder.Name = "ShopSounds"
	soundFolder.Parent = playerGui
	
	Sounds.Open = Instance.new("Sound")
	Sounds.Open.SoundId = "rbxassetid://9114488953"
	Sounds.Open.Volume = 0.5
	Sounds.Open.Parent = soundFolder
	
	Sounds.Hatch = Instance.new("Sound")
	Sounds.Hatch.SoundId = "rbxassetid://9113083740"
	Sounds.Hatch.Volume = 0.7
	Sounds.Hatch.Parent = soundFolder
	
	Sounds.Rare = Instance.new("Sound")
	Sounds.Rare.SoundId = "rbxassetid://9114483740"
	Sounds.Rare.Volume = 0.8
	Sounds.Rare.Parent = soundFolder
end

-- Create Shop UI
function createShopUI()
	if shopUI then
		shopUI:Destroy()
		shopUI = nil
		return
	end
	
	-- Main frame
	shopUI = Instance.new("ScreenGui")
	shopUI.Name = "HatchShopUI"
	shopUI.ResetOnSpawn = false
	shopUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	shopUI.Parent = playerGui
	
	-- Background dim
	local dim = Instance.new("Frame")
	dim.Name = "Dim"
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.5
	dim.BorderSizePixel = 0
	dim.Parent = shopUI
	
	-- Shop frame
	local shopFrame = Instance.new("Frame")
	shopFrame.Name = "ShopFrame"
	shopFrame.Size = UDim2.new(0, 500, 0, 450)
	shopFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
	shopFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	shopFrame.BorderSizePixel = 0
	shopFrame.Parent = shopUI
	
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 20)
	frameCorner.Parent = shopFrame
	
	local frameStroke = Instance.new("UIStroke")
	frameStroke.Color = Color3.fromRGB(100, 100, 120)
	frameStroke.Thickness = 3
	frameStroke.Parent = shopFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = "🥚 EGG SHOP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = shopFrame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -50, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextScaled = true
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = shopFrame
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		Sounds.Open:Play()
		createShopUI() -- Toggle off
	end)
	
	-- Egg container
	local container = Instance.new("ScrollingFrame")
	container.Name = "EggContainer"
	container.Size = UDim2.new(1, -40, 1, -90)
	container.Position = UDim2.new(0, 20, 0, 75)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 8
	container.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
	container.Parent = shopFrame
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 15)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = container
	
	-- Create egg cards
	for i, eggData in ipairs(EGGS) do
		createEggCard(eggData, container)
	end
	
	-- Auto-size canvas
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end)
	container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	
	-- Animate in
	shopFrame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(shopFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 500, 0, 450)
	}):Play()
	
	Sounds.Open:Play()
end

function createEggCard(eggData, parent)
	local card = Instance.new("Frame")
	card.Name = eggData.name .. "Card"
	card.Size = UDim2.new(0, 450, 0, 100)
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	card.BorderSizePixel = 0
	card.Parent = parent
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	-- Egg icon
	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 70, 0, 70)
	icon.Position = UDim2.new(0, 15, 0.5, -35)
	icon.BackgroundColor3 = eggData.color
	icon.BorderSizePixel = 0
	icon.Parent = card
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = icon
	
	-- Egg emoji
	local emoji = Instance.new("TextLabel")
	emoji.Name = "Emoji"
	emoji.Size = UDim2.new(1, 0, 1, 0)
	emoji.BackgroundTransparency = 1
	emoji.Text = "🥚"
	emoji.TextScaled = true
	emoji.Parent = icon
	
	-- Name
	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.Size = UDim2.new(0, 200, 0, 30)
	name.Position = UDim2.new(0, 100, 0, 15)
	name.BackgroundTransparency = 1
	name.Text = eggData.name
	name.TextColor3 = Color3.fromRGB(255, 255, 255)
	name.TextScaled = true
	name.Font = Enum.Font.GothamBold
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Parent = card
	
	-- Description
	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.new(0, 250, 0, 25)
	desc.Position = UDim2.new(0, 100, 0, 50)
	desc.BackgroundTransparency = 1
	desc.Text = eggData.description
	desc.TextColor3 = Color3.fromRGB(200, 200, 200)
	desc.TextScaled = true
	desc.Font = Enum.Font.Gotham
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = card
	
	-- Price & Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Name = "BuyButton"
	buyBtn.Size = UDim2.new(0, 100, 0, 50)
	buyBtn.Position = UDim2.new(1, -115, 0.5, -25)
	buyBtn.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
	buyBtn.Text = "💰 " .. eggData.price
	buyBtn.TextColor3 = Color3.fromRGB(0, 80, 0)
	buyBtn.TextScaled = true
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.Parent = card
	
	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyBtn
	
	-- Hover effects
	buyBtn.MouseEnter:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(120, 255, 120)
		}):Play()
	end)
	
	buyBtn.MouseLeave:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(85, 255, 85)
		}):Play()
	end)
	
	buyBtn.MouseButton1Click:Connect(function()
		buyEgg(eggData)
	end)
end

-- Buy egg and show hatching animation
function buyEgg(eggData)
	if isHatching then return end
	isHatching = true
	
	-- Close shop
	if shopUI then
		shopUI:Destroy()
		shopUI = nil
	end
	
	-- Create hatching UI
	local hatchUI = Instance.new("ScreenGui")
	hatchUI.Name = "HatchingUI"
	hatchUI.ResetOnSpawn = false
	hatchUI.Parent = playerGui
	
	-- Dim background
	local dim = Instance.new("Frame")
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.3
	dim.BorderSizePixel = 0
	dim.Parent = hatchUI
	
	-- Egg container
	local eggContainer = Instance.new("Frame")
	eggContainer.Size = UDim2.new(0, 200, 0, 200)
	eggContainer.Position = UDim2.new(0.5, -100, 0.5, -100)
	eggContainer.BackgroundTransparency = 1
	eggContainer.Parent = hatchUI
	
	-- Egg visual
	local egg = Instance.new("Frame")
	egg.Size = UDim2.new(1, 0, 1, 0)
	egg.BackgroundColor3 = eggData.color
	egg.BorderSizePixel = 0
	egg.Parent = eggContainer
	
	local eggCorner = Instance.new("UICorner")
	eggCorner.CornerRadius = UDim.new(0.5, 0)
	eggCorner.Parent = egg
	
	local eggGradient = Instance.new("UIGradient")
	eggGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, eggData.color),
		ColorSequenceKeypoint.new(1, Color3.new(
			math.clamp(eggData.color.R * 0.7, 0, 1),
			math.clamp(eggData.color.G * 0.7, 0, 1),
			math.clamp(eggData.color.B * 0.7, 0, 1)
		))
	})
	eggGradient.Parent = egg
	
	-- "Hatching..." text
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0, 300, 0, 40)
	text.Position = UDim2.new(0.5, -150, 0.5, 130)
	text.BackgroundTransparency = 1
	text.Text = "Hatching..."
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBlack
	text.Parent = hatchUI
	
	-- Shake animation
	local shakeTween = TweenService:Create(eggContainer, TweenInfo.new(0.1), {
		Rotation = 10
	})
	local shakeBack = TweenService:Create(eggContainer, TweenInfo.new(0.1), {
		Rotation = -10
	})
	local shakeReset = TweenService:Create(eggContainer, TweenInfo.new(0.1), {
		Rotation = 0
	})
	
	-- Chain the shake
	shakeTween:Play()
	shakeTween.Completed:Connect(function()
		shakeBack:Play()
	end)
	shakeBack.Completed:Connect(function()
		shakeReset:Play()
	end)
	
	Sounds.Hatch:Play()
	
	-- Server call for actual hatch
	local success, result = pcall(function()
		return HatchRequest:InvokeServer(eggData.id)
	end)
	
	-- Wait for animation
	delay(1.5, function()
		if success and result and result.success then
			-- Show result
			showHatchResult(result.pet, hatchUI)
		else
			-- Error
			text.Text = result and result.error or "Hatch failed!"
			text.TextColor3 = Color3.fromRGB(255, 80, 80)
			
			delay(2, function()
				hatchUI:Destroy()
				isHatching = false
			end)
		end
	end)
end

function showHatchResult(petData, hatchUI)
	-- Clear egg
	for _, child in ipairs(hatchUI:GetDescendants()) do
		if child:IsA("Frame") and child.Name ~= "Dim" then
			child:Destroy()
		end
	end
	
	-- Result container
	local resultContainer = Instance.new("Frame")
	resultContainer.Size = UDim2.new(0, 300, 0, 350)
	resultContainer.Position = UDim2.new(0.5, -150, 0.5, -175)
	resultContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	resultContainer.BorderSizePixel = 0
	resultContainer.Parent = hatchUI
	
	local resultCorner = Instance.new("UICorner")
	resultCorner.CornerRadius = UDim.new(0, 20)
	resultCorner.Parent = resultContainer
	
	-- Rarity colors
	local rarityColors = {
		Common = Color3.fromRGB(170, 170, 170),
		Uncommon = Color3.fromRGB(85, 255, 85),
		Rare = Color3.fromRGB(85, 165, 255),
		Epic = Color3.fromRGB(170, 85, 255),
		Legendary = Color3.fromRGB(255, 215, 0)
	}
	
	local color = rarityColors[petData.rarity] or Color3.fromRGB(255, 255, 255)
	
	-- "You got!" text
	local gotText = Instance.new("TextLabel")
	gotText.Size = UDim2.new(1, 0, 0, 40)
	gotText.Position = UDim2.new(0, 0, 0, 20)
	gotText.BackgroundTransparency = 1
	gotText.Text = "YOU GOT!"
	gotText.TextColor3 = Color3.fromRGB(255, 215, 0)
	gotText.TextScaled = true
	gotText.Font = Enum.Font.GothamBlack
	gotText.Parent = resultContainer
	
	-- Pet image
	local petImage = Instance.new("ImageLabel")
	petImage.Size = UDim2.new(0, 150, 0, 150)
	petImage.Position = UDim2.new(0.5, -75, 0, 70)
	petImage.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	petImage.Image = petData.imageId or "rbxassetid://3926305904"
	petImage.Parent = resultContainer
	
	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(1, 0)
	imageCorner.Parent = petImage
	
	local imageStroke = Instance.new("UIStroke")
	imageStroke.Color = color
	imageStroke.Thickness = 4
	imageStroke.Parent = petImage
	
	-- Glow effect for rare+ pets
	if petData.rarity == "Epic" or petData.rarity == "Legendary" then
		local glow = Instance.new("ImageLabel")
		glow.Size = UDim2.new(1.5, 0, 1.5, 0)
		glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
		glow.BackgroundTransparency = 1
		glow.Image = "rbxassetid://3926305904"
		glow.ImageColor3 = color
		glow.ImageTransparency = 0.7
		glow.ZIndex = -1
		glow.Parent = petImage
		
		-- Spin animation
		TweenService:Create(glow, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
			Rotation = 360
		}):Play()
		
		Sounds.Rare:Play()
	end
	
	-- Pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 35)
	nameLabel.Position = UDim2.new(0, 0, 0, 230)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = petData.name
	nameLabel.TextColor3 = color
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Parent = resultContainer
	
	-- Rarity badge
	local rarityBadge = Instance.new("TextLabel")
	rarityBadge.Size = UDim2.new(0, 150, 0, 25)
	rarityBadge.Position = UDim2.new(0.5, -75, 0, 270)
	rarityBadge.BackgroundColor3 = color
	rarityBadge.Text = petData.rarity:upper()
	rarityBadge.TextColor3 = Color3.fromRGB(0, 0, 0)
	rarityBadge.TextScaled = true
	rarityBadge.Font = Enum.Font.GothamBold
	rarityBadge.Parent = resultContainer
	
	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 6)
	badgeCorner.Parent = rarityBadge
	
	-- Multiplier
	local multLabel = Instance.new("TextLabel")
	multLabel.Size = UDim2.new(1, 0, 0, 20)
	multLabel.Position = UDim2.new(0, 0, 0, 300)
	multLabel.BackgroundTransparency = 1
	multLabel.Text = "💎 " .. petData.multiplier .. "x Coins"
	multLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	multLabel.TextScaled = true
	multLabel.Font = Enum.Font.Gotham
	multLabel.Parent = resultContainer
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 150, 0, 35)
	closeBtn.Position = UDim2.new(0.5, -75, 1, -50)
	closeBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	closeBtn.Text = "AWESOME!"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextScaled = true
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = resultContainer
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		TweenService:Create(resultContainer, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		
		delay(0.2, function()
			hatchUI:Destroy()
			isHatching = false
		end)
	end)
	
	-- Bounce in animation
	resultContainer.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(resultContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 300, 0, 350)
	}):Play()
end

-- Initialize
initSounds()

-- Expose
_G.HatchShopUI = {
	open = createShopUI,
	close = function() 
		if shopUI then
			shopUI:Destroy()
			shopUI = nil
		end
	end
}

print("[HatchShopUI] Initialized")