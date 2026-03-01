--[[
    CreatureConfig Module
    Stores all creature data, rarity weights, and egg configurations
    25 Creatures: 5 Elements × 5 Rarities
]]

local CreatureConfig = {}

-- Rarity definitions
CreatureConfig.Rarities = {
    Common = {
        weight = 50,
        multiplier = 1,
        color = Color3.fromRGB(169, 169, 169), -- Gray
        chancePercent = 50
    },
    Uncommon = {
        weight = 30,
        multiplier = 2,
        color = Color3.fromRGB(0, 255, 0), -- Green
        chancePercent = 30
    },
    Rare = {
        weight = 15,
        multiplier = 5,
        color = Color3.fromRGB(0, 100, 255), -- Blue
        chancePercent = 15
    },
    Epic = {
        weight = 4,
        multiplier = 10,
        color = Color3.fromRGB(128, 0, 255), -- Purple
        chancePercent = 4
    },
    Legendary = {
        weight = 1,
        multiplier = 50,
        color = Color3.fromRGB(255, 215, 0), -- Gold
        chancePercent = 1
    }
}

-- Total weight for RNG calculations
CreatureConfig.TotalWeight = 50 + 30 + 15 + 4 + 1

-- Creature data: 5 Elements × 5 Rarities = 25 creatures
CreatureConfig.Creatures = {
    -- FIRE ELEMENT
    fire_common_ember_pup = {
        id = "fire_common_ember_pup",
        name = "Ember Pup",
        element = "Fire",
        rarity = "Common",
        multiplier = 1,
        description = "A small pup with embers in its fur."
    },
    fire_uncommon_flame_fox = {
        id = "fire_uncommon_flame_fox",
        name = "Flame Fox",
        element = "Fire",
        rarity = "Uncommon",
        multiplier = 2,
        description = "A fox that dances through flames."
    },
    fire_rare_pyro_drake = {
        id = "fire_rare_pyro_drake",
        name = "Pyro Drake",
        element = "Fire",
        rarity = "Rare",
        multiplier = 5,
        description = "A young dragon that breathes fire."
    },
    fire_epic_inferno_wyrm = {
        id = "fire_epic_inferno_wyrm",
        name = "Inferno Wyrm",
        element = "Fire",
        rarity = "Epic",
        multiplier = 10,
        description = "Ancient wyrm of eternal flame."
    },
    fire_legendary_phoenix = {
        id = "fire_legendary_phoenix",
        name = "Phoenix",
        element = "Fire",
        rarity = "Legendary",
        multiplier = 50,
        description = "The immortal bird of rebirth."
    },

    -- WATER ELEMENT
    water_common_bubble_slime = {
        id = "water_common_bubble_slime",
        name = "Bubble Slime",
        element = "Water",
        rarity = "Common",
        multiplier = 1,
        description = "A squishy slime full of bubbles."
    },
    water_uncommon_tide_turtle = {
        id = "water_uncommon_tide_turtle",
        name = "Tide Turtle",
        element = "Water",
        rarity = "Uncommon",
        multiplier = 2,
        description = "Turtle that rides the ocean tides."
    },
    water_rare_aqua_serpent = {
        id = "water_rare_aqua_serpent",
        name = "Aqua Serpent",
        element = "Water",
        rarity = "Rare",
        multiplier = 5,
        description = "Serpent of the deep blue sea."
    },
    water_epic_tsunami_leviathan = {
        id = "water_epic_tsunami_leviathan",
        name = "Tsunami Leviathan",
        element = "Water",
        rarity = "Epic",
        multiplier = 10,
        description = "Titan that commands the waves."
    },
    water_legendary_kraken = {
        id = "water_legendary_kraken",
        name = "Kraken",
        element = "Water",
        rarity = "Legendary",
        multiplier = 50,
        description = "The legendary sea monster."
    },

    -- EARTH ELEMENT
    earth_common_pebble_sprite = {
        id = "earth_common_pebble_sprite",
        name = "Pebble Sprite",
        element = "Earth",
        rarity = "Common",
        multiplier = 1,
        description = "A tiny spirit of small stones."
    },
    earth_uncommon_moss_boar = {
        id = "earth_uncommon_moss_boar",
        name = "Moss Boar",
        element = "Earth",
        rarity = "Uncommon",
        multiplier = 2,
        description = "Boar covered in ancient moss."
    },
    earth_rare_stone_golem = {
        id = "earth_rare_stone_golem",
        name = "Stone Golem",
        element = "Earth",
        rarity = "Rare",
        multiplier = 5,
        description = "Animated guardian of the mountains."
    },
    earth_epic_terra_titan = {
        id = "earth_epic_terra_titan",
        name = "Terra Titan",
        element = "Earth",
        rarity = "Epic",
        multiplier = 10,
        description = "Giant that shapes the earth itself."
    },
    earth_legendary_earth_dragon = {
        id = "earth_legendary_earth_dragon",
        name = "Earth Dragon",
        element = "Earth",
        rarity = "Legendary",
        multiplier = 50,
        description = "Dragon born from the planet's core."
    },

    -- AIR ELEMENT
    air_common_gust_sprite = {
        id = "air_common_gust_sprite",
        name = "Gust Sprite",
        element = "Air",
        rarity = "Common",
        multiplier = 1,
        description = "Playful spirit of gentle breezes."
    },
    air_uncommon_cloud_wolf = {
        id = "air_uncommon_cloud_wolf",
        name = "Cloud Wolf",
        element = "Air",
        rarity = "Uncommon",
        multiplier = 2,
        description = "Wolf that runs on clouds."
    },
    air_rare_storm_hawk = {
        id = "air_rare_storm_hawk",
        name = "Storm Hawk",
        element = "Air",
        rarity = "Rare",
        multiplier = 5,
        description = "Hawk that rides lightning."
    },
    air_epic_thunderbird = {
        id = "air_epic_thunderbird",
        name = "Thunderbird",
        element = "Air",
        rarity = "Epic",
        multiplier = 10,
        description = "Mythical bird of thunder."
    },
    air_legendary_sky_leviathan = {
        id = "air_legendary_sky_leviathan",
        name = "Sky Leviathan",
        element = "Air",
        rarity = "Legendary",
        multiplier = 50,
        description = "Titan that swims through the sky."
    },

    -- VOID ELEMENT
    void_common_shadow_blob = {
        id = "void_common_shadow_blob",
        name = "Shadow Blob",
        element = "Void",
        rarity = "Common",
        multiplier = 1,
        description = "A creature of pure darkness."
    },
    void_uncommon_dark_wolf = {
        id = "void_uncommon_dark_wolf",
        name = "Dark Wolf",
        element = "Void",
        rarity = "Uncommon",
        multiplier = 2,
        description = "Wolf from the shadow realm."
    },
    void_rare_abyss_beast = {
        id = "void_rare_abyss_beast",
        name = "Abyss Beast",
        element = "Void",
        rarity = "Rare",
        multiplier = 5,
        description = "Horror from the endless abyss."
    },
    void_epic_void_stalker = {
        id = "void_epic_void_stalker",
        name = "Void Stalker",
        element = "Void",
        rarity = "Epic",
        multiplier = 10,
        description = "Hunter from between dimensions."
    },
    void_legendary_chaos_dragon = {
        id = "void_legendary_chaos_dragon",
        name = "Chaos Dragon",
        element = "Void",
        rarity = "Legendary",
        multiplier = 50,
        description = "Dragon of pure chaos energy."
    }
}

-- Egg configurations
CreatureConfig.Eggs = {
    Basic = {
        id = "basic",
        name = "Basic Egg",
        cost = 100,
        description = "Contains creatures of all elements.",
        allowedElements = {"Fire", "Water", "Earth", "Air", "Void"},
        rarityModifiers = {} -- Standard chances
    },
    Fire = {
        id = "fire",
        name = "Fire Egg",
        cost = 250,
        description = "Fire creatures only. Better rare chance!",
        allowedElements = {"Fire"},
        rarityModifiers = {
            Rare = 20,      -- +5% chance
            Epic = 6,       -- +2% chance
            Legendary = 1.5 -- +0.5% chance
        }
    },
    Water = {
        id = "water",
        name = "Water Egg",
        cost = 250,
        description = "Water creatures only.",
        allowedElements = {"Water"},
        rarityModifiers = {}
    },
    Earth = {
        id = "earth",
        name = "Earth Egg",
        cost = 250,
        description = "Earth creatures only.",
        allowedElements = {"Earth"},
        rarityModifiers = {}
    },
    Void = {
        id = "void",
        name = "Void Egg",
        cost = 500,
        description = "Void creatures with boosted epic/legend rates!",
        allowedElements = {"Void"},
        rarityModifiers = {
            Rare = 20,
            Epic = 8,       -- +4% chance
            Legendary = 2   -- +1% chance
        }
    }
}

-- Helper functions
function CreatureConfig:GetCreatureById(id)
    return self.Creatures[id]
end

function CreatureConfig:GetCreaturesByElement(element)
    local result = {}
    for id, creature in pairs(self.Creatures) do
        if creature.element == element then
            result[id] = creature
        end
    end
    return result
end

function CreatureConfig:GetCreaturesByRarity(rarity)
    local result = {}
    for id, creature in pairs(self.Creatures) do
        if creature.rarity == rarity then
            result[id] = creature
        end
    end
    return result
end

function CreatureConfig:GetRarityFromRoll(roll, modifiers)
    -- Apply modifiers if provided
    local weights = {
        Common = modifiers and modifiers.Common or self.Rarities.Common.weight,
        Uncommon = modifiers and modifiers.Uncommon or self.Rarities.Uncommon.weight,
        Rare = modifiers and modifiers.Rare or self.Rarities.Rare.weight,
        Epic = modifiers and modifiers.Epic or self.Rarities.Epic.weight,
        Legendary = modifiers and modifiers.Legendary or self.Rarities.Legendary.weight
    }
    
    local total = weights.Common + weights.Uncommon + weights.Rare + weights.Epic + weights.Legendary
    local normalizedRoll = (roll / self.TotalWeight) * total
    
    local cumulative = 0
    cumulative = cumulative + weights.Common
    if normalizedRoll <= cumulative then return "Common" end
    
    cumulative = cumulative + weights.Uncommon
    if normalizedRoll <= cumulative then return "Uncommon" end
    
    cumulative = cumulative + weights.Rare
    if normalizedRoll <= cumulative then return "Rare" end
    
    cumulative = cumulative + weights.Epic
    if normalizedRoll <= cumulative then return "Epic" end
    
    return "Legendary"
end

return CreatureConfig
