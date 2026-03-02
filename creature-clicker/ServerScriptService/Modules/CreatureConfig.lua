--[[
    CreatureConfig Module
    Stores all creature data, rarity weights, and egg configurations
    Updated: Multiple egg types and creature rarity system
]]

local CreatureConfig = {}

-- Rarity definitions with multiplier ranges
CreatureConfig.Rarities = {
    Common = {
        weight = 70,
        minMultiplier = 1.1,
        maxMultiplier = 1.5,
        color = Color3.fromRGB(169, 169, 169), -- Gray
        chancePercent = 70
    },
    Uncommon = {
        weight = 25,
        minMultiplier = 1.6,
        maxMultiplier = 2.5,
        color = Color3.fromRGB(0, 255, 0), -- Green
        chancePercent = 25
    },
    Rare = {
        weight = 4.5,
        minMultiplier = 3.0,
        maxMultiplier = 5.0,
        color = Color3.fromRGB(0, 100, 255), -- Blue
        chancePercent = 4.5
    },
    Epic = {
        weight = 0.4,
        minMultiplier = 6.0,
        maxMultiplier = 9.0,
        color = Color3.fromRGB(128, 0, 255), -- Purple
        chancePercent = 0.4
    },
    Legendary = {
        weight = 0.1,
        minMultiplier = 10.0,
        maxMultiplier = 15.0,
        color = Color3.fromRGB(255, 215, 0), -- Gold
        chancePercent = 0.1
    }
}

-- Helper to get random multiplier for a rarity
function CreatureConfig:GetRandomMultiplier(rarity)
    local rarityData = self.Rarities[rarity]
    if not rarityData then return 1.0 end
    
    local rng = Random.new()
    local range = rarityData.maxMultiplier - rarityData.minMultiplier
    return rarityData.minMultiplier + (rng:NextNumber() * range)
end

-- Total weight for RNG calculations (used as base)
CreatureConfig.TotalWeight = 100

-- Creature data by rarity tiers
CreatureConfig.Creatures = {
    -- COMMON TIER (Froggle, Sneetle + new common creatures)
    froggle = {
        id = "froggle",
        name = "Froggle",
        element = "Water",
        rarity = "Common",
        description = "A bouncy little frog creature.",
        image = "rbxassetid://12345"
    },
    sneetle = {
        id = "sneetle",
        name = "Sneetle",
        element = "Earth",
        rarity = "Common",
        description = "A sneaky beetle that hides in sand.",
        image = "rbxassetid://12346"
    },
    pebble_sprite = {
        id = "pebble_sprite",
        name = "Pebble Sprite",
        element = "Earth",
        rarity = "Common",
        description = "A tiny spirit of small stones.",
        image = "rbxassetid://12347"
    },
    bubble_slime = {
        id = "bubble_slime",
        name = "Bubble Slime",
        element = "Water",
        rarity = "Common",
        description = "A squishy slime full of bubbles.",
        image = "rbxassetid://12348"
    },

    -- UNCOMMON TIER (Bunnip, Glowbug)
    bunnip = {
        id = "bunnip",
        name = "Bunnip",
        element = "Earth",
        rarity = "Uncommon",
        description = "A fluffy bunny with leaf ears.",
        image = "rbxassetid://12349"
    },
    glowbug = {
        id = "glowbug",
        name = "Glowbug",
        element = "Void",
        rarity = "Uncommon",
        description = "A bug that glows in the dark.",
        image = "rbxassetid://12350"
    },
    flame_fox = {
        id = "flame_fox",
        name = "Flame Fox",
        element = "Fire",
        rarity = "Uncommon",
        description = "A fox that dances through flames.",
        image = "rbxassetid://12351"
    },
    tide_turtle = {
        id = "tide_turtle",
        name = "Tide Turtle",
        element = "Water",
        rarity = "Uncommon",
        description = "Turtle that rides the ocean tides.",
        image = "rbxassetid://12352"
    },

    -- RARE TIER (Drakeling, Phoenix)
    drakeling = {
        id = "drakeling",
        name = "Drakeling",
        element = "Fire",
        rarity = "Rare",
        description = "A young dragon with fiery breath.",
        image = "rbxassetid://12353"
    },
    phoenix = {
        id = "phoenix",
        name = "Phoenix",
        element = "Fire",
        rarity = "Rare",
        description = "A mystical bird that rises from ashes.",
        image = "rbxassetid://12354"
    },
    aqua_serpent = {
        id = "aqua_serpent",
        name = "Aqua Serpent",
        element = "Water",
        rarity = "Rare",
        description = "Serpent of the deep blue sea.",
        image = "rbxassetid://12355"
    },
    stone_golem = {
        id = "stone_golem",
        name = "Stone Golem",
        element = "Earth",
        rarity = "Rare",
        description = "Animated guardian of the mountains.",
        image = "rbxassetid://12356"
    },

    -- EPIC TIER (Leviathan)
    leviathan = {
        id = "leviathan",
        name = "Leviathan",
        element = "Water",
        rarity = "Epic",
        description = "A massive sea monster of legend.",
        image = "rbxassetid://12357"
    },
    inferno_wyrm = {
        id = "inferno_wyrm",
        name = "Inferno Wyrm",
        element = "Fire",
        rarity = "Epic",
        description = "Ancient wyrm of eternal flame.",
        image = "rbxassetid://12358"
    },
    thunderbird = {
        id = "thunderbird",
        name = "Thunderbird",
        element = "Air",
        rarity = "Epic",
        description = "Mythical bird of thunder.",
        image = "rbxassetid://12359"
    },

    -- LEGENDARY TIER (Kraken, Dragon)
    kraken = {
        id = "kraken",
        name = "Kraken",
        element = "Water",
        rarity = "Legendary",
        description = "The legendary sea monster of the abyss.",
        image = "rbxassetid://12360"
    },
    dragon = {
        id = "dragon",
        name = "Dragon",
        element = "Fire",
        rarity = "Legendary",
        description = "The ultimate fire-breathing beast.",
        image = "rbxassetid://12361"
    },
    chaos_dragon = {
        id = "chaos_dragon",
        name = "Chaos Dragon",
        element = "Void",
        rarity = "Legendary",
        description = "Dragon of pure chaos energy.",
        image = "rbxassetid://12362"
    }
}

-- Egg configurations with rarity weights
CreatureConfig.Eggs = {
    Basic = {
        id = "Basic",
        name = "Basic Egg",
        cost = 10,
        description = "A basic egg with common creatures.",
        rarityWeights = {
            Common = 70,
            Uncommon = 25,
            Rare = 5,
            Epic = 0,
            Legendary = 0
        }
    },
    Fire = {
        id = "Fire",
        name = "Fire Egg",
        cost = 50,
        description = "Fire creatures with better odds!",
        element = "Fire",
        rarityWeights = {
            Common = 50,
            Uncommon = 35,
            Rare = 12,
            Epic = 3,
            Legendary = 0
        }
    },
    Water = {
        id = "Water",
        name = "Water Egg",
        cost = 50,
        description = "Water creatures with better odds!",
        element = "Water",
        rarityWeights = {
            Common = 50,
            Uncommon = 35,
            Rare = 12,
            Epic = 3,
            Legendary = 0
        }
    },
    Earth = {
        id = "Earth",
        name = "Earth Egg",
        cost = 50,
        description = "Earth creatures with better odds!",
        element = "Earth",
        rarityWeights = {
            Common = 50,
            Uncommon = 35,
            Rare = 12,
            Epic = 3,
            Legendary = 0
        }
    },
    Void = {
        id = "Void",
        name = "Void Egg",
        cost = 150,
        description = "Void creatures with EPIC odds!",
        element = "Void",
        rarityWeights = {
            Common = 0,
            Uncommon = 40,
            Rare = 35,
            Epic = 20,
            Legendary = 5
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

function CreatureConfig:GetCreaturesByElementAndRarity(element, rarity)
    local result = {}
    for id, creature in pairs(self.Creatures) do
        if creature.element == element and creature.rarity == rarity then
            table.insert(result, creature)
        end
    end
    return result
end

-- Roll for rarity based on egg type weights
function CreatureConfig:RollRarity(eggType)
    local eggConfig = self.Eggs[eggType]
    if not eggConfig then
        eggConfig = self.Eggs.Basic
    end
    
    local weights = eggConfig.rarityWeights
    local totalWeight = 0
    
    for rarity, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local rng = Random.new()
    local roll = rng:NextNumber(0, totalWeight)
    local cumulative = 0
    
    cumulative = cumulative + (weights.Common or 0)
    if roll <= cumulative then return "Common" end
    
    cumulative = cumulative + (weights.Uncommon or 0)
    if roll <= cumulative then return "Uncommon" end
    
    cumulative = cumulative + (weights.Rare or 0)
    if roll <= cumulative then return "Rare" end
    
    cumulative = cumulative + (weights.Epic or 0)
    if roll <= cumulative then return "Epic" end
    
    return "Legendary"
end

-- Get a random creature from an egg
function CreatureConfig:GetRandomCreatureFromEgg(eggType)
    local eggConfig = self.Eggs[eggType]
    if not eggConfig then
        eggConfig = self.Eggs.Basic
    end
    
    -- Roll for rarity
    local rarity = self:RollRarity(eggType)
    
    -- Get creatures matching rarity
    local candidates = {}
    
    if eggConfig.element then
        -- Element-specific egg
        candidates = self:GetCreaturesByElementAndRarity(eggConfig.element, rarity)
    else
        -- Basic egg - any element
        candidates = self:GetCreaturesByRarity(rarity)
        -- Convert to array
        local temp = {}
        for _, creature in pairs(candidates) do
            table.insert(temp, creature)
        end
        candidates = temp
    end
    
    -- If no candidates for this rarity/element combo, fall back to any creature of that rarity
    if #candidates == 0 then
        local allOfRarity = self:GetCreaturesByRarity(rarity)
        for _, creature in pairs(allOfRarity) do
            table.insert(candidates, creature)
        end
    end
    
    -- Still no candidates? Fall back to common
    if #candidates == 0 then
        local commons = self:GetCreaturesByRarity("Common")
        for _, creature in pairs(commons) do
            table.insert(candidates, creature)
        end
    end
    
    -- Pick random candidate
    local rng = Random.new()
    local selected = candidates[rng:NextInteger(1, #candidates)]
    
    -- Generate random multiplier for this instance
    local multiplier = self:GetRandomMultiplier(rarity)
    
    return {
        id = selected.id,
        name = selected.name,
        element = selected.element,
        rarity = selected.rarity,
        multiplier = multiplier,
        description = selected.description,
        image = selected.image
    }
end

return CreatureConfig
