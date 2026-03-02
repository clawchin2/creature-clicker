-- Config.lua
-- Shared configuration for Creature Simulator
-- Used by both Server and Client

local Config = {}

-- Economy settings
Config.STARTING_COINS = 100
Config.PASSIVE_INCOME_INTERVAL = 1 -- seconds
Config.BASE_CLICK_VALUE = 1

-- Egg definitions
Config.EggTypes = {
	Basic = { 
		price = 10, 
		name = "Basic Egg", 
		description = "A simple egg. Good for beginners.",
		color = Color3.fromRGB(200, 200, 200),
		emoji = "🥚",
	},
	Fire = { 
		price = 50, 
		name = "Fire Egg", 
		description = "Warm to the touch. Contains fire creatures.",
		color = Color3.fromRGB(255, 100, 50),
		emoji = "🔥",
	},
	Water = { 
		price = 50, 
		name = "Water Egg", 
		description = "Cool and damp. Water creatures inside.",
		color = Color3.fromRGB(50, 100, 255),
		emoji = "💧",
	},
	Earth = { 
		price = 50, 
		name = "Earth Egg", 
		description = "Heavy and solid. Earth creatures dwell within.",
		color = Color3.fromRGB(100, 200, 50),
		emoji = "🌿",
	},
	Void = { 
		price = 150, 
		name = "Void Egg", 
		description = "Mysterious and dark. Contains rare void creatures.",
		color = Color3.fromRGB(100, 50, 150),
		emoji = "🌑",
	},
}

-- Rarity drop rates per egg type
Config.CreatureRarities = {
	Basic = {
		{ rarity = "Common", chance = 70, multiplierRange = {1.1, 1.5} },
		{ rarity = "Uncommon", chance = 25, multiplierRange = {1.6, 2.5} },
		{ rarity = "Rare", chance = 5, multiplierRange = {3.0, 4.0} },
	},
	Fire = {
		{ rarity = "Common", chance = 50, multiplierRange = {1.5, 2.0} },
		{ rarity = "Uncommon", chance = 35, multiplierRange = {2.1, 3.0} },
		{ rarity = "Rare", chance = 12, multiplierRange = {3.5, 5.0} },
		{ rarity = "Legendary", chance = 3, multiplierRange = {6.0, 8.0} },
	},
	Water = {
		{ rarity = "Common", chance = 50, multiplierRange = {1.5, 2.0} },
		{ rarity = "Uncommon", chance = 35, multiplierRange = {2.1, 3.0} },
		{ rarity = "Rare", chance = 12, multiplierRange = {3.5, 5.0} },
		{ rarity = "Legendary", chance = 3, multiplierRange = {6.0, 8.0} },
	},
	Earth = {
		{ rarity = "Common", chance = 50, multiplierRange = {1.5, 2.0} },
		{ rarity = "Uncommon", chance = 35, multiplierRange = {2.1, 3.0} },
		{ rarity = "Rare", chance = 12, multiplierRange = {3.5, 5.0} },
		{ rarity = "Legendary", chance = 3, multiplierRange = {6.0, 8.0} },
	},
	Void = {
		{ rarity = "Uncommon", chance = 40, multiplierRange = {2.5, 3.5} },
		{ rarity = "Rare", chance = 35, multiplierRange = {4.0, 6.0} },
		{ rarity = "Legendary", chance = 20, multiplierRange = {7.0, 10.0} },
		{ rarity = "Mythic", chance = 5, multiplierRange = {12.0, 20.0} },
	},
}

-- Creature name pools per rarity
Config.CreatureNames = {
	Common = {"Pebble", "Sprout", "Spark", "Droplet", "Breeze", "Dusty", "Nibble", "Pip"},
	Uncommon = {"Ember", "Ripple", "Stone", "Gust", "Fluff", "Sparkle", "Moss", "Pebbleton"},
	Rare = {"Inferno", "Tsunami", "Avalanche", "Tempest", "Shadow", "Blaze", "Frost", "Nova"},
	Legendary = {"Phoenix", "Leviathan", "Titan", "Cyclone", "Voidling", "Drakon", "Zephyr", "Onyx"},
	Mythic = {"Cosmos", "Eternity", "Oblivion", "Genesis", "Apocalypse", "Infinity", "Celestial", "Primal"},
}

-- Rarity display settings
Config.RaritySettings = {
	Common = {
		color = Color3.fromRGB(169, 169, 169),
		emoji = "🐭",
		glowIntensity = 0.5,
	},
	Uncommon = {
		color = Color3.fromRGB(50, 205, 50),
		emoji = "🐰",
		glowIntensity = 0.6,
	},
	Rare = {
		color = Color3.fromRGB(30, 144, 255),
		emoji = "🦊",
		glowIntensity = 0.7,
	},
	Legendary = {
		color = Color3.fromRGB(255, 215, 0),
		emoji = "🐉",
		glowIntensity = 0.8,
	},
	Mythic = {
		color = Color3.fromRGB(255, 0, 255),
		emoji = "👑",
		glowIntensity = 1.0,
	},
}

-- Hatch settings
Config.HATCH_DURATION = 3 -- seconds for animation
Config.AUTO_EQUIP_BETTER = true -- Auto-equip if new creature is better

-- Passive income formula: multiplier * PASSIVE_INCOME_RATE
Config.PASSIVE_INCOME_RATE = 0.1 -- 10% of multiplier per second

return Config
