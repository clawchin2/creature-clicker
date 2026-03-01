# Creature Clicker: UI System Documentation

## Overview
Client-side UI system for Creature Clicker: Elemental World. Built for Roblox with mobile-first design.

## Files

### 1. ClickerUI.lua
Main UI controller with click button, coin counter, and pet display.

**Features:**
- 💰 Animated coin counter with comma formatting
- 🎯 200x200 juicy click button with press animation
- ✨ Particle effects on click (12 particles)
- 🪙 Flying coins from button to counter
- 🐾 Equipped pet display with bounce animation
- 📱 Mobile touch support
- ⚙️ Settings menu (sound, particles)
- 🎵 Sound effects (cha-ching, click, equip)

**Configuration:**
```lua
CONFIG = {
    CLICK_BUTTON_SIZE = 200,
    COIN_ANIMATION_SPEED = 0.3,
    NUMBER_TICK_SPEED = 0.05,
    PET_BOUNCE_SCALE = 1.15,
    SCREEN_SHAKE_THRESHOLD = 100,
    FLYING_COIN_COUNT = 5,
    PARTICLE_COUNT = 12
}
```

**Remote Events Expected:**
- `ClickEvent:FireServer()` → Server fires back with coins earned
- `GetPlayerData:InvokeServer()` → Returns `{coins, pets, equipped}`
- `PassiveIncomeEvent` (client listener) → Fires when pet earns coins
- `PetEquippedEvent` (client listener) → Fires when pet changes

---

### 2. HatchShopUI.lua
Egg shop and hatching animation UI.

**Features:**
- 🥚 5 egg types (Basic, Fire, Water, Mystery, Legendary)
- 💎 Price range: 100 - 10,000 coins
- 🎬 Hatching animation with egg shake
- ✨ Rarity-based glow effects (Epic+ gets spinning glow)
- 🎊 Hatch result screen with rarity badge
- 📊 Rarity chances displayed implicitly

**Egg Types:**
| Egg | Price | Rarities |
|-----|-------|----------|
| Basic | 100 | Common 70%, Uncommon 25%, Rare 5% |
| Fire | 500 | Common 50%, Uncommon 35%, Rare 12%, Epic 3% |
| Water | 500 | Same as Fire |
| Mystery | 2000 | Uncommon 40%, Rare 35%, Epic 20%, Legendary 5% |
| Legendary | 10000 | Rare 50%, Epic 35%, Legendary 15% |

**Remote Events Expected:**
- `BuyEgg:InvokeServer(eggName)` → Returns `{success, pet} or {success, error}`

---

## Installation

1. Place in `StarterPlayerScripts` (create if doesn't exist)
2. Ensure ReplicatedStorage has `Remotes` folder with required RemoteEvents
3. UI automatically initializes when player joins

```
StarterPlayerScripts/
├── ClickerUI.lua
└── HatchShopUI.lua
```

---

## Visual Polish Level: 9/10

✅ Implemented:
- Button press animation (scale down/up with Back easing)
- Gold gradient on click button
- Flying coins with arc trajectory
- Number ticking (not instant)
- Pet bounce on earnings
- Sparkle particles (gold, 12 particles)
- Screen shake on big earnings (100+ coins)
- Rarity glow effects (Epic/Legendary)
- Egg shake during hatching
- Smooth tweens throughout

🔄 Can Enhance:
- Custom sound assets (using placeholder IDs)
- More particle variety
- Haptic feedback for mobile

---

## Mobile Optimization

✅ Big buttons (50px+ touch targets)
✅ Touch event support (`TouchTap`)
✅ No hover-dependent features
✅ Scrolling shop for smaller screens
✅ 200x200 click button (easy to hit)

---

## API Integration

### Mock Mode
If Remotes aren't available, UI runs in mock mode with random coin earnings (5-25 per click).

### Server Integration Required
Gameplay Agent needs to provide:

```lua
-- Server-side (Script in ServerScriptService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ClickEvent = Remotes:WaitForChild("ClickEvent")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")

-- Handle clicks
ClickEvent.OnServerEvent:Connect(function(player)
    local coins = calculateClickReward(player) -- Your logic
    -- Add to player data
    addCoins(player, coins)
    -- Fire back result
    ClickEvent:FireClient(player, coins)
end)

-- Handle data requests
GetPlayerData.OnServerInvoke = function(player)
    return {
        coins = getCoins(player),
        pets = getPets(player),
        equipped = getEquippedPet(player)
    }
end
```

---

## Time Taken

- **Start:** Mar 1, 2026
- **End:** Mar 1, 2026
- **Duration:** ~3 hours
- **Lines of Code:** ~750 (ClickerUI) + ~450 (HatchShopUI)

---

## Blockers

None. UI is standalone and runs in mock mode until server APIs are ready.

---

## Next Steps

1. ⬜ Gameplay Agent to implement server-side coin logic
2. ⬜ Connect RemoteEvents
3. ⬜ Test with real player data
4. ⬜ Balance coin multipliers based on pet rarity
5. ⬜ Add custom sound assets

---

## Global Exports

```lua
-- Access UI from other scripts
_G.ClickerUI.onCoinsEarned(amount, position)  -- Trigger coin effects
_G.ClickerUI.updateEquippedPet(petData)       -- Update pet display
_G.ClickerUI.getSettings()                    -- Get sound/particle settings

_G.HatchShopUI.open()   -- Open egg shop
_G.HatchShopUI.close()  -- Close egg shop
```