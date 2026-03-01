# CREATURE CLICKER: BUILD TRACKER
## Daily Status & Progress

### PROJECT OVERVIEW
**Game:** Creature Clicker: Elemental World
**Target:** ₹10-20L/month at 25K DAU
**Timeline:** 4 weeks (Mar 1-28, 2026)
**Status:** 🟡 Week 1 In Progress

---

## WEEK 1: CORE LOOP (Mar 1-7)
**Goal:** Click → Earn → Hatch → Passively earn
**Status:** 🟡 In Progress (40%)

### Day 1-2: Gameplay Core [100%] ✅
- [x] Player data system (coins, pets, rebirths) - PlayerData.lua (318 lines)
- [x] DataStore save/load - Auto-save 60s + on exit
- [x] Click to earn coins - Rate-limited 10/sec
- [x] Server-side coin validation - Server-authoritative
- [x] 25 Creatures config - CreatureConfig.lua (365 lines)
- [x] 5 Egg types with RNG - HatchSystem.lua (324 lines)
- [x] Passive income system - Every 5s from pets - PassiveIncome.lua (124 lines)
- [x] Click handler - ClickHandler.lua (204 lines)
- [x] Rebirth bonus (+10% per rebirth) - Main.server.lua (205 lines)
**Agent:** gameplay-code-w1
**ETA:** Mar 2, 2026 ✅ COMPLETE (110 min)

### Day 3-4: UI Foundation [100%]
- [x] Click button with particle effects (200x200, juicy animations)
- [x] Coin counter UI (animated, flying coins, number ticking)
- [x] Pet display (equipped pet with multiplier, bounce animation)
- [x] Sound on click (cha-ching, pop, equip sounds)
- [x] Screen shake on big earnings
- [x] Settings menu (sound/particles toggle)
- [x] Hatch shop UI with hatching animation
**Agent:** ui-code-1
**ETA:** Mar 4, 2026 ✅ COMPLETE

### Day 5-7: Integration & Validation [🟡 IN PROGRESS]
- [x] Egg shop (5 egg types) - Server & Client
- [x] Hatching animation - UI complete
- [x] RNG rarity system - Server complete
- [x] Passive income from pets - Server complete
- [x] Validation Agent testing - ✅ COMPLETE
- [x] Bug fixes based on validation - ✅ FIXED
  - [x] table.clone -> deepCopy (PlayerData.lua)
  - [x] Admin command security (Main.server.lua)
  - [x] Client-Server RemoteEvents sync
  - [x] Egg price mismatch fixed
- [ ] Economy balancing
**Agents:** validation-week1 + fixes
**ETA:** Mar 7, 2026

**MILESTONE 1:** Can click, earn, hatch, earn passively ✅

---

## WEEK 2: PROGRESSION & MONEY (Mar 8-14)
**Goal:** Rebirth system + Monetization
**Status:** ⬜ Not Started

### Day 8-10: Rebirth System [0%]
- [ ] Rebirth logic (reset + multiplier)
- [ ] Rebirth milestones
- [ ] Multiplier display
**Agent:** TBD
**ETA:** Mar 10, 2026

### Day 11-14: Monetization [0%]
- [ ] Auto-clicker gamepass (₹199)
- [ ] 2x Forever gamepass (₹199)
- [ ] DevProduct: Rebirth skip (₹49)
- [ ] DevProduct: 2x boost 1hr (₹29)
**Agents:** TBD
**ETA:** Mar 14, 2026

**MILESTONE 2:** Monetization live, rebirth working ✅

---

## WEEK 3: RETENTION (Mar 15-21)
**Goal:** Daily rewards + Lucky spin
**Status:** ⬜ Not Started

### Day 15-17: Daily Systems [0%]
- [ ] Daily login rewards
- [ ] Streak tracking
- [ ] Lucky spin wheel (4hr cooldown)
**Agent:** TBD
**ETA:** Mar 17, 2026

### Day 18-21: Social [0%]
- [ ] Leaderboard (richest players)
- [ ] Simple trading
- [ ] Economy balancing
**Agents:** TBD + validation
**ETA:** Mar 21, 2026

**MILESTONE 3:** Retention hooks live, economy balanced ✅

---

## WEEK 4: SHIP (Mar 22-28)
**Goal:** Polish + Soft launch
**Status:** ⬜ Not Started

### Day 22-25: Polish [0%]
- [ ] Particle effects everywhere
- [ ] Sound effects
- [ ] Mobile optimization
- [ ] Bug fixes
**Agent:** TBD
**ETA:** Mar 25, 2026

### Day 26-28: Launch [0%]
- [ ] Final testing
- [ ] Soft launch
- [ ] Analytics setup
**Agents:** All + validation
**ETA:** Mar 28, 2026

**MILESTONE 4:** Game live, revenue tracking ✅

---

## CREATURE DESIGN SPEC

### Total: 25 Creatures
**5 Elements × 5 Rarities each**

**Elements:**
1. Fire (red/orange theme)
2. Water (blue theme)
3. Earth (green/brown theme)
4. Air (white/cloud theme)
5. Void (purple/black theme)

**Rarities per Element:**
| Rarity | Chance | Coin Multiplier | Color |
|--------|--------|-----------------|-------|
| Common | 50% | 1x | Gray |
| Uncommon | 30% | 2x | Green |
| Rare | 15% | 5x | Blue |
| Epic | 4% | 10x | Purple |
| Legendary | 1% | 50x | Gold |

**Example Creatures:**
- Fire: Ember Pup, Flame Fox, Pyro Drake, Inferno Wyrm, Phoenix
- Water: Bubble Slime, Tide Turtle, Aqua Serpent, Tsunami Leviathan, Kraken
- Earth: Pebble Sprite, Moss Boar, Stone Golem, Terra Titan, Earth Dragon
- Air: Gust Sprite, Cloud Wolf, Storm Hawk, Thunderbird, Sky Leviathan
- Void: Shadow Blob, Dark Wolf, Abyss Beast, Void Stalker, Chaos Dragon

**Visual Design:**
- Use Roblox free models as base
- Recolor by element
- Add rarity glow effects
- Simple idle animation (bounce/float)

**Stats per Creature:**
- Name
- Element
- Rarity
- Coin multiplier
- Image ID
- Description

---

## AGENT ASSIGNMENTS

| Agent | Current Task | Status | ETA |
|-------|-------------|--------|-----|
| gameplay-code-w1 | Player data + clicking | ✅ COMPLETE | Mar 1 |
| ui-code-w1 | Click button + particles | ✅ COMPLETE | Mar 1 |
| validation-week1 | Testing Week 1 integration | 🟡 RUNNING | Mar 1 |

---

## DAILY LOG

### Mar 1, 2026 (Sun)
- ✅ Project approved (Option A - Simple)
- ✅ Build tracker created
- ✅ Week 1 plan finalized
- ✅ UI Code Agent COMPLETE: ClickerUI.lua + HatchShopUI.lua
  - 200x200 juicy click button with press animation
  - Particle effects (12 sparkles on click)
  - Flying coins from button to counter
  - Animated coin counter with number ticking
  - Pet display with bounce animation
  - Sound effects (cha-ching, pop, equip)
  - Screen shake on big earnings (100+ coins)
  - Settings menu (sound/particles toggles)
  - Hatch shop with 5 egg types
  - Hatching animation with egg shake
  - Rarity glow effects (Epic+ gets spinning glow)
  - Mobile-friendly touch targets

### Mar 2, 2026 (Mon)
- ⬜ Pending

---

## BLOCKERS
None currently.

## NOTES
- Keep first 10 creatures free (tutorial)
- Generous free rewards (avoid P2W feel)
- Test economy after Week 1 (can rebalance)
