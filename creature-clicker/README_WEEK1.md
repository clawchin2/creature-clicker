# Creature Clicker - Week 1 Server Implementation

## Files Created

### Core Modules
```
ServerScriptService/
├── Main.server.lua              # Entry point, initializes all systems
└── Modules/
    ├── CreatureConfig.lua       # 25 creatures, rarities, eggs config
    ├── PlayerData.lua           # DataStore, player session management
    ├── ClickHandler.lua         # Server-validated clicking, rate limiting
    ├── HatchSystem.lua          # Egg hatching, RNG system
    └── PassiveIncome.lua        # Passive coin generation
```

**Total: 6 files, ~450 lines of Lua**

---

## DataStore Structure

```lua
{
    coins = 0,                    -- number
    pets = {                      -- table: creatureId -> count
        ["fire_common_ember_pup"] = 2,
        ["water_rare_aqua_serpent"] = 1
    },
    rebirths = 0,                 -- number
    equipped = "fire_common_ember_pup",  -- string or nil
    stats = {
        totalClicks = 0,
        totalCoinsEarned = 0,
        creaturesHatched = 0,
        joinTime = 0
    }
}
```

---

## RemoteEvents/Functions (API for UI Agent)

All remotes are in `ReplicatedStorage.CreatureClickerRemotes`

### Clicking System

| Remote | Type | Direction | Payload | Response |
|--------|------|-----------|---------|----------|
| `ClickRequest` | RemoteEvent | Client → Server | (no args) | Fire `ClickResponse` |
| `ClickResponse` | RemoteEvent | Server → Client | `{success, coinsEarned, totalCoins, multiplier, error}` | - |

**Rate Limit:** 10 clicks/second per player (enforced server-side)

**ClickResponse fields:**
- `success` (boolean)
- `coinsEarned` (number) - Coins from this click
- `totalCoins` (number) - Player's new total
- `multiplier` (number) - Current click multiplier from equipped pet
- `error` (string, optional) - Error message if failed

### Player Data

| Remote | Type | Direction | Returns |
|--------|------|-----------|---------|
| `GetPlayerData` | RemoteFunction | Client → Server | `{coins, pets, rebirths, equipped, passiveIncome, clickMultiplier}` |

### Hatch System

| Remote | Type | Direction | Payload | Returns/Fires |
|--------|------|-----------|---------|---------------|
| `GetEggsInfo` | RemoteFunction | Client → Server | - | Array of egg info with rarity chances |
| `HatchRequest` | RemoteEvent | Client → Server | `eggType` (string: "Basic", "Fire", "Water", "Earth", "Void") | Fire `HatchResult` |
| `HatchResult` | RemoteEvent | Server → Client | `{success, creature, remainingCoins, error}` | - |

**HatchResult.creature fields:**
- `id` (string)
- `name` (string)
- `element` (string)
- `rarity` (string: "Common", "Uncommon", "Rare", "Epic", "Legendary")
- `multiplier` (number)
- `description` (string)

### Inventory/Pets

| Remote | Type | Direction | Payload | Returns |
|--------|------|-----------|---------|---------|
| `GetCreatures` | RemoteFunction | Client → Server | - | Array of owned creatures with count |
| `EquipPet` | RemoteFunction | Client → Server | `creatureId` (string) | `{success, equipped}` |
| `UnequipPet` | RemoteFunction | Client → Server | - | `{success}` |

**GetCreatures returns:**
```lua
{
    {
        id = "fire_common_ember_pup",
        name = "Ember Pup",
        element = "Fire",
        rarity = "Common",
        multiplier = 1,
        description = "...",
        count = 3,
        equipped = true/false
    },
    ...
}
```

### Passive Income

| Remote | Type | Direction | Returns |
|--------|------|-----------|---------|
| `GetPassiveIncomePreview` | RemoteFunction | Client → Server | `{perInterval, perMinute, perHour}` |
| `PassiveIncome` | RemoteEvent | Server → Client | `{amount, totalCoins, interval}` |

The `PassiveIncome` event fires every 5 seconds when player earns passive coins.

### Config

| Remote | Type | Direction | Returns |
|--------|------|-----------|---------|
| `GetCreatureConfig` | RemoteFunction | Client → Server | Full config (rarities, creatures, eggs) |

---

## Creature Configuration

### Rarities (5 tiers)

| Rarity | Weight | Chance | Multiplier |
|--------|--------|--------|------------|
| Common | 50 | 50% | 1x |
| Uncommon | 30 | 30% | 2x |
| Rare | 15 | 15% | 5x |
| Epic | 4 | 4% | 10x |
| Legendary | 1 | 1% | 50x |

### Elements (5 types)
- Fire (red/orange)
- Water (blue)
- Earth (green/brown)
- Air (white/cloud)
- Void (purple/black)

### 25 Creatures

**Fire:**
- Common: Ember Pup (1x)
- Uncommon: Flame Fox (2x)
- Rare: Pyro Drake (5x)
- Epic: Inferno Wyrm (10x)
- Legendary: Phoenix (50x)

**Water:**
- Common: Bubble Slime (1x)
- Uncommon: Tide Turtle (2x)
- Rare: Aqua Serpent (5x)
- Epic: Tsunami Leviathan (10x)
- Legendary: Kraken (50x)

**Earth:**
- Common: Pebble Sprite (1x)
- Uncommon: Moss Boar (2x)
- Rare: Stone Golem (5x)
- Epic: Terra Titan (10x)
- Legendary: Earth Dragon (50x)

**Air:**
- Common: Gust Sprite (1x)
- Uncommon: Cloud Wolf (2x)
- Rare: Storm Hawk (5x)
- Epic: Thunderbird (10x)
- Legendary: Sky Leviathan (50x)

**Void:**
- Common: Shadow Blob (1x)
- Uncommon: Dark Wolf (2x)
- Rare: Abyss Beast (5x)
- Epic: Void Stalker (10x)
- Legendary: Chaos Dragon (50x)

---

## Egg Types

| Egg | Cost | Elements | Special |
|-----|------|----------|---------|
| Basic | 100 | All | Standard rates |
| Fire | 250 | Fire only | +5% Rare, +2% Epic, +0.5% Legendary |
| Water | 250 | Water only | Standard rates |
| Earth | 250 | Earth only | Standard rates |
| Void | 500 | Void only | +5% Rare, +4% Epic, +1% Legendary |

---

## Economy Math

### Click Earnings
```
Base: 1 coin per click
Multiplier: Equipped pet's multiplier (1x-50x)
Rebirth bonus: +10% per rebirth
Formula: coins = floor(1 × petMultiplier × (1 + rebirths × 0.1))
```

**Examples:**
- No pet, no rebirth: 1 coin
- Rare pet (5x), no rebirth: 5 coins
- Legendary pet (50x), 5 rebirths: 50 × 1.5 = 75 coins

### Passive Income
```
Each pet gives: multiplier × 0.1 coins per 5 seconds
Rebirth bonus: +10% per rebirth
Formula: income = floor(sum(petMultiplier × count × 0.1) × (1 + rebirths × 0.1))
```

**Examples:**
- 10 Common pets (1x): 10 × 0.1 = 1 coin / 5s = 12/min
- 5 Rare pets (5x): 25 × 0.1 = 2.5 → 2 coins / 5s = 24/min
- Legendary (50x) + 5 rebirths: 50 × 0.1 × 1.5 = 7.5 → 7 coins / 5s

---

## Admin Commands (Dev Only)

| Command | Description |
|---------|-------------|
| `/givecoins [amount]` | Add coins to self |
| `/resetdata` | Reset all player data |

---

## Blockers/Issues

**None.** All Week 1 Day 1-2 deliverables complete.

---

## Next Steps for UI Agent

1. **Click Button:** Call `ClickRequest`, listen for `ClickResponse`
2. **Coin Display:** Poll `GetPlayerData` or track from events
3. **Egg Shop:** Call `GetEggsInfo`, display costs and chances
4. **Hatching:** Call `HatchRequest`, show `HatchResult` animation
5. **Inventory:** Call `GetCreatures`, display with equip/unequip buttons
6. **Passive Income:** Listen for `PassiveIncome` event, display preview

---

## Time Taken

- Setup & planning: 5 min
- CreatureConfig module: 15 min
- PlayerData module: 20 min
- ClickHandler module: 15 min
- HatchSystem module: 20 min
- PassiveIncome module: 10 min
- Main server script: 15 min
- Documentation: 10 min

**Total: ~110 minutes (1h 50m)**
