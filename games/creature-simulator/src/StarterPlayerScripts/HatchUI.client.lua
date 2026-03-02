-- HatchUI.client.lua
-- Client-side UI controller for hatching system
-- Connects to server remotes for egg buying and hatching

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remotes to be created
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local buyEggRemote = remotesFolder:WaitForChild("BuyEgg")
local hatchEggRemote = remotesFolder:WaitForChild("HatchEgg")
local getInventoryRemote = remotesFolder:WaitForChild("GetInventory")
local coinsUpdated = remotesFolder:WaitForChild("CoinsUpdated")
local creatureHatched = remotesFolder:WaitForChild("CreatureHatched")
local creatureEquipped = remotesFolder:WaitForChild("CreatureEquipped")

local HatchUI = {}

-- UI Element references
HatchUI.Elements = {}
HatchUI.State = {
	coins = 0,
	eggs = {},
	creatures = {},
	equippedCreature = nil,
	isHatching = false,
	selectedEgg = nil,
}

-- Rarity colors
local RARITY_COLORS = {
	Common = Color3.fromRGB(169, 169, 169),
	Uncommon = Color3.fromRGB(50, 205, 50),
	Rare = Color3.fromRGB(30, 144, 255),
	Legendary = Color3.fromRGB(255, 215, 0),
	Mythic = Color3.fromRGB(255, 0, 255),
}

-- Create the main UI
function HatchUI:CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HatchUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	self.Elements.screenGui = screenGui
	
	-- Coin display
	self:CreateCoinDisplay(screenGui)
	
	-- Hatch button
	self:CreateHatchButton(screenGui)
	
	-- Egg shop
	self:CreateEggShop(screenGui)
	
	-- Egg inventory
	self:CreateEggInventory(screenGui)
	
	-- Hatch animation overlay
	self:CreateHatchOverlay(screenGui)
	
	-- Creature reveal modal
	self:CreateCreatureReveal(screenGui)
	
	print("[HatchUI] UI created successfully")
end

function HatchUI:CreateCoinDisplay(parent)
	local coinFrame = Instance.new("Frame")
	coinFrame.Name = "CoinDisplay"
	coinFrame.Size = UDim2.new(0, 200, 0, 50)
	coinFrame.Position = UDim2.new(0, 20, 0, 20)
	coinFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	coinFrame.BorderSizePixel = 0
	coinFrame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = coinFrame
	
	local coinIcon = Instance.new("TextLabel")
	coinIcon.Name = "Icon"
	coinIcon.Size = UDim2.new(0, 40, 1, 0)
	coinIcon.BackgroundTransparency = 1
	coinIcon.Text = "🪙"
	coinIcon.TextSize = 24
	coinIcon.Parent = coinFrame
	
	local coinText = Instance.new("TextLabel")
	coinText.Name = "Amount"
	coinText.Size = UDim2.new(1, -50, 1, 0)
	coinText.Position = UDim2.new(0, 50, 0, 0)
	coinText.BackgroundTransparency = 1
	coinText.Text = "0"
	coinText.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinText.TextSize = 24
	coinText.Font = Enum.Font.GothamBold
	coinText.TextXAlignment = Enum.TextXAlignment.Left
	coinText.Parent = coinFrame
	
	self.Elements.coinText = coinText
end

function HatchUI:CreateHatchButton(parent)
	local button = Instance.new("TextButton")
	button.Name = "HatchButton"
	button.Size = UDim2.new(0, 150, 0, 50)
	button.Position = UDim2.new(0.5, -75, 0.9, 0)
	button.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
	button.Text = "🥚 HATCH"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 20
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(150, 100, 255)
	stroke.Thickness = 2
	stroke.Parent = button
	
	button.MouseButton1Click:Connect(function()
		self:ToggleEggShop()
	end)
	
	self.Elements.hatchButton = button
end

function HatchUI:CreateEggShop(parent)
	local shopFrame = Instance.new("Frame")
	shopFrame.Name = "EggShop"
	shopFrame.Size = UDim2.new(0, 500, 0, 400)
	shopFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	shopFrame.BorderSizePixel = 0
	shopFrame.Visible = false
	shopFrame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = shopFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "🥚 EGG SHOP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.Parent = shopFrame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	closeBtn.TextSize = 24
	closeBtn.Parent = shopFrame
	
	closeBtn.MouseButton1Click:Connect(function()
		shopFrame.Visible = false
	end)
	
	-- Scrolling frame for eggs
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "EggList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = shopFrame
	
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 140, 0, 180)
	layout.CellPadding = UDim2.new(0, 10, 0, 10)
	layout.Parent = scrollFrame
	
	self.Elements.eggShop = shopFrame
	self.Elements.eggList = scrollFrame
end

function HatchUI:CreateEggInventory(parent)
	local invFrame = Instance.new("Frame")
	invFrame.Name = "EggInventory"
	invFrame.Size = UDim2.new(0, 400, 0, 150)
	invFrame.Position = UDim2.new(0.5, -200, 0.72, 0)
	invFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	invFrame.BorderSizePixel = 0
	invFrame.Visible = false
	invFrame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = invFrame
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundTransparency = 1
	title.Text = "YOUR EGGS (Click to Hatch)"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.Parent = invFrame
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "InventoryList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -40)
	scrollFrame.Position = UDim2.new(0, 10, 0, 35)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.Parent = invFrame
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scrollFrame
	
	self.Elements.eggInventory = invFrame
	self.Elements.inventoryList = scrollFrame
end

function HatchUI:CreateHatchOverlay(parent)
	local overlay = Instance.new("Frame")
	overlay.Name = "HatchOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Visible = false
	overlay.Parent = parent
	
	local eggFrame = Instance.new("Frame")
	eggFrame.Name = "EggFrame"
	eggFrame.Size = UDim2.new(0, 200, 0, 250)
	eggFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
	eggFrame.BackgroundTransparency = 1
	eggFrame.Parent = overlay
	
	local eggEmoji = Instance.new("TextLabel")
	eggEmoji.Name = "EggEmoji"
	eggEmoji.Size = UDim2.new(1, 0, 0, 150)
	eggEmoji.BackgroundTransparency = 1
	eggEmoji.Text = "🥚"
	eggEmoji.TextSize = 120
	eggEmoji.Parent = eggFrame
	
	local progressText = Instance.new("TextLabel")
	progressText.Name = "Progress"
	progressText.Size = UDim2.new(1, 0, 0, 50)
	progressText.Position = UDim2.new(0, 0, 0.7, 0)
	progressText.BackgroundTransparency = 1
	progressText.Text = "Hatching..."
	progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressText.TextSize = 24
	progressText.Parent = eggFrame
	
	self.Elements.hatchOverlay = overlay
	self.Elements.hatchEggEmoji = eggEmoji
	self.Elements.hatchProgress = progressText
end

function HatchUI:CreateCreatureReveal(parent)
	local revealFrame = Instance.new("Frame")
	revealFrame.Name = "CreatureReveal"
	revealFrame.Size = UDim2.new(0, 400, 0, 500)
	revealFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	revealFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	revealFrame.BorderSizePixel = 0
	revealFrame.Visible = false
	revealFrame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = revealFrame
	
	-- Rarity glow background
	local glow = Instance.new("Frame")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 0, 0, 200)
	glow.BackgroundTransparency = 0.8
	glow.Parent = revealFrame
	
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 20)
	glowCorner.Parent = glow
	
	-- Creature emoji
	local creatureEmoji = Instance.new("TextLabel")
	creatureEmoji.Name = "CreatureEmoji"
	creatureEmoji.Size = UDim2.new(1, 0, 0, 150)
	creatureEmoji.Position = UDim2.new(0, 0, 0, 25)
	creatureEmoji.BackgroundTransparency = 1
	creatureEmoji.Text = "❓"
	creatureEmoji.TextSize = 100
	creatureEmoji.Parent = revealFrame
	
	-- Rarity label
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(1, 0, 0, 30)
	rarityLabel.Position = UDim2.new(0, 0, 0, 190)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = "RARITY"
	rarityLabel.TextSize = 20
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = revealFrame
	
	-- Creature name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "CreatureName"
	nameLabel.Size = UDim2.new(1, 0, 0, 40)
	nameLabel.Position = UDim2.new(0, 0, 0.45, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Creature Name"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 28
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = revealFrame
	
	-- Multiplier display
	local multFrame = Instance.new("Frame")
	multFrame.Name = "MultiplierFrame"
	multFrame.Size = UDim2.new(0, 200, 0, 60)
	multFrame.Position = UDim2.new(0.5, -100, 0.6, 0)
	multFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	multFrame.Parent = revealFrame
	
	local multCorner = Instance.new("UICorner")
	multCorner.CornerRadius = UDim.new(0, 8)
	multCorner.Parent = multFrame
	
	local multLabel = Instance.new("TextLabel")
	multLabel.Name = "Label"
	multLabel.Size = UDim2.new(1, 0, 0, 20)
	multLabel.BackgroundTransparency = 1
	multLabel.Text = "COIN MULTIPLIER"
	multLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	multLabel.TextSize = 12
	multLabel.Parent = multFrame
	
	local multValue = Instance.new("TextLabel")
	multValue.Name = "Value"
	multValue.Size = UDim2.new(1, 0, 0, 35)
	multValue.Position = UDim2.new(0, 0, 0, 20)
	multValue.BackgroundTransparency = 1
	multValue.Text = "x1.0"
	multValue.TextColor3 = Color3.fromRGB(255, 215, 0)
	multValue.TextSize = 28
	multValue.Font = Enum.Font.GothamBold
	multValue.Parent = multFrame
	
	-- Equipped indicator
	local equippedLabel = Instance.new("TextLabel")
	equippedLabel.Name = "EquippedLabel"
	equippedLabel.Size = UDim2.new(1, 0, 0, 30)
	equippedLabel.Position = UDim2.new(0, 0, 0.75, 0)
	equippedLabel.BackgroundTransparency = 1
	equippedLabel.Text = "✓ AUTO-EQUIPPED"
	equippedLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
	equippedLabel.TextSize = 18
	equippedLabel.Visible = false
	equippedLabel.Parent = revealFrame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 200, 0, 50)
	closeBtn.Position = UDim2.new(0.5, -100, 0.85, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
	closeBtn.Text = "AWESOME!"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 20
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = revealFrame
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 12)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		revealFrame.Visible = false
	end)
	
	self.Elements.creatureReveal = revealFrame
	self.Elements.creatureGlow = glow
	self.Elements.creatureEmoji = creatureEmoji
	self.Elements.creatureName = nameLabel
	self.Elements.creatureRarity = rarityLabel
	self.Elements.creatureMultiplier = multValue
	self.Elements.equippedLabel = equippedLabel
end

-- Populate egg shop from server data
function HatchUI:PopulateEggShop(shopData)
	-- Clear existing
	for _, child in ipairs(self.Elements.eggList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Create egg buttons
	for _, eggData in ipairs(shopData) do
		local eggButton = self:CreateEggCard(eggData)
		eggButton.Parent = self.Elements.eggList
	end
	
	-- Update canvas size
	local layout = self.Elements.eggList:FindFirstChildOfClass("UIGridLayout")
	if layout then
		local rows = math.ceil(#shopData / 3)
		self.Elements.eggList.CanvasSize = UDim2.new(0, 0, 0, rows * 190 + 10)
	end
end

function HatchUI:CreateEggCard(eggData)
	local card = Instance.new("TextButton")
	card.Name = eggData.type .. "Egg"
	card.Size = UDim2.new(0, 140, 0, 180)
	card.BackgroundColor3 = eggData.color or Color3.fromRGB(200, 200, 200)
	card.Text = ""
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card
	
	-- Egg icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(1, 0, 0, 80)
	icon.BackgroundTransparency = 1
	icon.Text = "🥚"
	icon.TextSize = 60
	icon.Parent = card
	
	-- Egg name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = eggData.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = card
	
	-- Price button
	local priceBtn = Instance.new("TextLabel")
	priceBtn.Name = "Price"
	priceBtn.Size = UDim2.new(0.8, 0, 0, 35)
	priceBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
	priceBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	priceBtn.Text = "🪙 " .. eggData.price
	priceBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	priceBtn.TextSize = 18
	priceBtn.Font = Enum.Font.GothamBold
	priceBtn.Parent = card
	
	local priceCorner = Instance.new("UICorner")
	priceCorner.CornerRadius = UDim.new(0, 6)
	priceCorner.Parent = priceBtn
	
	-- Click handler
	card.MouseButton1Click:Connect(function()
		self:BuyEgg(eggData.type)
	end)
	
	return card
end

-- Populate inventory display
function HatchUI:UpdateInventory(data)
	self.State.coins = data.coins
	self.State.eggs = data.eggs
	self.State.creatures = data.creatures
	self.State.equippedCreature = data.equippedCreature
	
	-- Update coin display
	self.Elements.coinText.Text = tostring(math.floor(data.coins))
	
	-- Update egg inventory display
	self:RefreshEggInventory()
end

function HatchUI:RefreshEggInventory()
	-- Clear existing
	for _, child in ipairs(self.Elements.inventoryList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Count eggs
	local eggCount = 0
	for eggId, eggData in pairs(self.State.eggs) do
		eggCount += 1
		local eggButton = self:CreateInventoryEgg(eggId, eggData)
		eggButton.Parent = self.Elements.inventoryList
	end
	
	-- Show/hide inventory based on egg count
	self.Elements.eggInventory.Visible = eggCount > 0
	
	-- Update canvas size
	local layout = self.Elements.inventoryList:FindFirstChildOfClass("UIListLayout")
	if layout then
		self.Elements.inventoryList.CanvasSize = UDim2.new(0, eggCount * 110, 0, 0)
	end
end

function HatchUI:CreateInventoryEgg(eggId, eggData)
	local button = Instance.new("TextButton")
	button.Name = eggId
	button.Size = UDim2.new(0, 100, 0, 100)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.Text = ""
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 0, 60)
	icon.BackgroundTransparency = 1
	icon.Text = "🥚"
	icon.TextSize = 50
	icon.Parent = button
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.Position = UDim2.new(0, 0, 0.65, 0)
	label.BackgroundTransparency = 1
	label.Text = "Click to Hatch"
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 12
	label.Parent = button
	
	button.MouseButton1Click:Connect(function()
		self:HatchEgg(eggId)
	end)
	
	return button
end

-- Actions
function HatchUI:ToggleEggShop()
	local isVisible = self.Elements.eggShop.Visible
	self.Elements.eggShop.Visible = not isVisible
	
	if not isVisible then
		-- Refresh shop data when opening
		self:FetchInventory()
	end
end

function HatchUI:BuyEgg(eggType)
	print("[HatchUI] Buying egg: " .. eggType)
	
	local result = buyEggRemote:InvokeServer(eggType)
	
	if result.success then
		print("[HatchUI] Bought egg successfully: " .. result.egg.name)
		self:ShowNotification("Bought " .. result.egg.name .. "!", Color3.fromRGB(50, 255, 50))
		self:RefreshEggInventory()
	else
		print("[HatchUI] Failed to buy egg: " .. tostring(result.error))
		self:ShowNotification(result.error, Color3.fromRGB(255, 50, 50))
	end
end

function HatchUI:HatchEgg(eggId)
	if self.State.isHatching then return end
	
	print("[HatchUI] Hatching egg: " .. eggId)
	self.State.isHatching = true
	self.State.selectedEgg = eggId
	
	-- Show hatch animation
	self:PlayHatchAnimation()
	
	-- Call server
	local result = hatchEggRemote:InvokeServer(eggId)
	
	-- Hide animation
	self.Elements.hatchOverlay.Visible = false
	self.State.isHatching = false
	
	if result.success then
		print("[HatchUI] Hatched: " .. result.creature.name .. " (" .. result.creature.rarity .. ")")
		self:ShowCreatureReveal(result.creature, result.equipped)
		self:RefreshEggInventory()
	else
		print("[HatchUI] Failed to hatch: " .. tostring(result.error))
		self:ShowNotification(result.error, Color3.fromRGB(255, 50, 50))
	end
end

function HatchUI:PlayHatchAnimation()
	local overlay = self.Elements.hatchOverlay
	local eggEmoji = self.Elements.hatchEggEmoji
	local progressText = self.Elements.hatchProgress
	
	overlay.Visible = true
	
	-- Shake animation
	local shakeTween = TweenService:Create(eggEmoji, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 30), {
		Rotation = 15
	})
	shakeTween:Play()
	
	-- Progress updates
	for i = 1, 3 do
		progressText.Text = "Hatching" .. string.rep(".", i)
		wait(0.8)
	end
	
	shakeTween:Cancel()
	eggEmoji.Rotation = 0
end

function HatchUI:ShowCreatureReveal(creature, wasEquipped)
	local reveal = self.Elements.creatureReveal
	
	-- Set data
	self.Elements.creatureName.Text = creature.name
	self.Elements.creatureRarity.Text = creature.rarity:upper()
	self.Elements.creatureMultiplier.Text = "x" .. creature.multiplier
	self.Elements.equippedLabel.Visible = wasEquipped
	
	-- Set colors based on rarity
	local rarityColor = RARITY_COLORS[creature.rarity] or Color3.fromRGB(169, 169, 169)
	self.Elements.creatureGlow.BackgroundColor3 = rarityColor
	self.Elements.creatureRarity.TextColor3 = rarityColor
	
	-- Set creature emoji based on rarity
	local emojis = {
		Common = "🐭",
		Uncommon = "🐰",
		Rare = "🦊",
		Legendary = "🐉",
		Mythic = "👑",
	}
	self.Elements.creatureEmoji.Text = emojis[creature.rarity] or "🐾"
	
	-- Show with animation
	reveal.Visible = true
	reveal.Size = UDim2.new(0, 300, 0, 375)
	reveal.Position = UDim2.new(0.5, -150, 0.5, -187)
	
	local popTween = TweenService:Create(reveal, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 400, 0, 500),
		Position = UDim2.new(0.5, -200, 0.5, -250),
	})
	popTween:Play()
end

function HatchUI:ShowNotification(text, color)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 300, 0, 50)
	notif.Position = UDim2.new(0.5, -150, 0, -60)
	notif.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
	notif.BorderSizePixel = 0
	notif.Parent = self.Elements.screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notif
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.Font = Enum.Font.GothamBold
	label.Parent = notif
	
	-- Animate in
	local inTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -150, 0, 80),
	})
	inTween:Play()
	
	-- Remove after delay
	wait(2.5)
	
	local outTween = TweenService:Create(notif, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, -150, 0, -60),
	})
	outTween:Play()
	
	outTween.Completed:Connect(function()
		notif:Destroy()
	end)
end

-- Server communication
function HatchUI:FetchInventory()
	local result = getInventoryRemote:InvokeServer()
	
	if result.success then
		self:UpdateInventory(result.inventory)
		if result.shop then
			self:PopulateEggShop(result.shop)
		end
	else
		warn("[HatchUI] Failed to fetch inventory: " .. tostring(result.error))
	end
end

-- Event handlers
function HatchUI:SetupEventHandlers()
	-- Coins updated from server
	coinsUpdated.OnClientEvent:Connect(function(newCoins)
		self.State.coins = newCoins
		self.Elements.coinText.Text = tostring(math.floor(newCoins))
		
		-- Coin change animation
		local goalSize = UDim2.new(0, 210, 0, 55)
		local normalSize = UDim2.new(0, 200, 0, 50)
		
		local popTween = TweenService:Create(self.Elements.coinText.Parent, TweenInfo.new(0.1), {
			Size = goalSize,
			Position = UDim2.new(0, 15, 0, 17),
		})
		popTween:Play()
		
		wait(0.1)
		
		local backTween = TweenService:Create(self.Elements.coinText.Parent, TweenInfo.new(0.1), {
			Size = normalSize,
			Position = UDim2.new(0, 20, 0, 20),
		})
		backTween:Play()
	end)
	
	-- Creature hatched (for visual effects)
	creatureHatched.OnClientEvent:Connect(function(data)
		print("[HatchUI] " .. data.playerName .. " hatched a " .. data.creature.rarity .. " creature!")
		-- Could show a world notification here
	end)
	
	-- Creature equipped
	creatureEquipped.OnClientEvent:Connect(function(data)
		print("[HatchUI] Creature equipped with x" .. data.multiplier .. " multiplier")
		self:ShowNotification("Creature Equipped! x" .. data.multiplier .. " coins", Color3.fromRGB(100, 255, 100))
	end)
end

-- Initialization
function HatchUI:Init()
	print("[HatchUI] Initializing...")
	
	self:CreateUI()
	self:SetupEventHandlers()
	self:FetchInventory()
	
	print("[HatchUI] Initialization complete")
end

-- Start
HatchUI:Init()

return HatchUI
