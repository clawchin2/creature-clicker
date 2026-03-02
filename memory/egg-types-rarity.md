# Creature Clicker - Egg Types & Rarity System

## Changes Made - March 2, 2026

### 1. Multiple Egg Types Added

| Egg Type | Cost | Rarity Distribution |
|----------|------|---------------------|
| **Basic Egg** | 10 coins | 70% Common, 25% Uncommon, 5% Rare, 0% Epic, 0% Legendary |
| **Fire Egg** | 50 coins | 50% Common, 35% Uncommon, 12% Rare, 3% Epic, 0% Legendary |
| **Water Egg** | 50 coins | 50% Common, 35% Uncommon, 12% Rare, 3% Epic, 0% Legendary |
| **Earth Egg** | 50 coins | 50% Common, 35% Uncommon, 12% Rare, 3% Epic, 0% Legendary |
| **Void Egg** | 150 coins | 0% Common, 40% Uncommon, 35% Rare, 20% Epic, 5% Legendary |

### 2. Creature Rarity System

| Rarity | Multiplier Range | Creatures |
|--------|-----------------|-----------|
| **Common** | 1.1x - 1.5x | Froggle, Sneetle, Pebble Sprite, Bubble Slime |
| **Uncommon** | 1.6x - 2.5x | Bunnip, Glowbug, Flame Fox, Tide Turtle |
| **Rare** | 3.0x - 5.0x | Drakeling, Phoenix, Aqua Serpent, Stone Golem |
| **Epic** | 6.0x - 9.0x | Leviathan, Inferno Wyrm, Thunderbird |
| **Legendary** | 10.0x - 15.0x | Kraken, Dragon, Chaos Dragon |

### 3. Server API Updates

#### BuyEgg Remote
```lua
-- Accepts eggType parameter
BuyEgg:InvokeServer(eggType) -- eggType: "Basic", "Fire", "Water", "Earth", "Void"

-- Returns:
{
    success = true/false,
    remainingCoins = number,
    creatureName = string,
    creatureId = string,
    rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
    multiplier = number,
    element = string,
    description = string
}
```

#### GetEggTypes Remote (NEW)
```lua
-- Returns list of all egg types with their costs and rarity chances
GetEggTypes:InvokeServer()
```

### 4. Files Modified

- `/creature-clicker/ServerScriptService/Modules/CreatureConfig.lua` - Complete rewrite with rarity system
- `/creature-clicker/ServerScriptService/Main.server.lua` - Updated BuyEgg and added GetEggTypes

### 5. Test Notes

**Manual Testing Checklist:**
- [ ] Buy Basic Egg (10 coins) - should get Common 70% of the time
- [ ] Buy Fire Egg (50 coins) - should have better Rare/Epic odds
- [ ] Buy Void Egg (150 coins) - should get Epic/Legendary sometimes
- [ ] Verify multiplier is within range for each rarity
- [ ] Verify creature matches egg element (Fire egg = Fire creature)
- [ ] Check inventory shows rarity info correctly

**Expected Behaviors:**
- Insufficient coins returns appropriate error message with required amount
- Invalid egg type returns error
- Each creature instance gets random multiplier within rarity range
- Rarities are saved but multipliers are generated fresh each time
