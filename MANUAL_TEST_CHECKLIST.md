# MANUAL TESTING CHECKLIST - Creature Clicker Week 1

## Build Info
- **Build File:** `CreatureClicker-Week1.rbxl`
- **GitHub:** https://github.com/clawchin2/creature-clicker
- **Commit:** cb5cc55 (Week 1 COMPLETE)

---

## PRE-TEST SETUP

1. Download `CreatureClicker-Week1.rbxl` from workspace
2. Open Roblox Studio
3. File → Open → Select `CreatureClicker-Week1.rbxl`
4. Press F5 to play test

---

## TEST 1: FIRST 60 SECONDS (Critical)

### Starting State
- [ ] You spawn with **5 coins** (shown top-right)
- [ ] Click button is visible (center, big gold button)
- [ ] Pet display shows "No Pet Equipped"

### First Click
- [ ] Click the button → **+5 coins popup** appears
- [ ] Sound plays (cha-ching)
- [ ] Coin counter updates to **10**

### Second Click
- [ ] Another **+5 popup**
- [ ] Counter shows **15**

### Buy First Egg
- [ ] Click "HATCH" button (bottom right)
- [ ] Egg shop opens
- [ ] Basic Egg costs **10 coins**
- [ ] Buy Basic Egg

### Hatch Experience
- [ ] Egg shaking animation plays
- [ ] Sound plays
- [ ] **GUARANTEED RARE** creature hatches (not Common)
- [ ] Rarity badge shows "RARE" in blue
- [ ] Creature name displayed
- [ ] Click "AWESOME!" to close

### After Hatch
- [ ] Pet display shows equipped creature
- [ ] Shows **5x multiplier** (or whatever Rare gives)
- [ ] Pet image pulses/bounces (idle animation)
- [ ] Shows **+X/sec** passive income

### Test New Click Power
- [ ] Click button → Now gives **25 coins** (5 base × 5x multiplier)
- [ ] **+25 popup** appears

**If all above works:** First 60 seconds = PERFECT ✅

---

## TEST 2: ECONOMY PROGRESSION

### Buy More Eggs
- [ ] Click until you have 50 coins
- [ ] Buy Fire/Water/Earth Egg (50 coins each)
- [ ] Hatch animation plays
- [ ] Get random creature

### Check Passive Income
- [ ] Wait 5 seconds without clicking
- [ ] Coins should increase automatically
- [ ] Check that **+X/sec** display updates

### Rebirth Test (if you have time)
- [ ] Play until you have significant coins
- [ ] Check if rebirth option appears (may not be visible in UI yet)

---

## TEST 3: DATA PERSISTENCE

### Save Test
- [ ] Play for 2-3 minutes
- [ ] Note your coin count and creatures
- [ ] Exit play mode (F5)
- [ ] Re-enter play mode (F5)
- [ ] Check if coins/creatures saved correctly

**Expected:** Data should persist between sessions (uses DataStore)

---

## TEST 4: EDGE CASES

### Spam Clicking
- [ ] Click as fast as possible for 10 seconds
- [ ] Should be rate-limited to 10 clicks/second max
- [ ] No errors in output console

### Multiple Eggs
- [ ] Buy 5-10 eggs in a row
- [ ] Check that inventory tracks correctly
- [ ] Each hatch should show proper animation

### Equip/Unequip
- [ ] Hatch multiple creatures
- [ ] Check if you can switch equipped pet (UI may not have equip button yet)
- [ ] Multiplier should update when switching

---

## BUG REPORT TEMPLATE

If you find issues, report like this:

```
**Bug:** [Short description]
**Severity:** [Critical/Major/Minor]
**Steps:** 
1. [What you did]
2. [What happened]
3. [What should happen]
**Screenshot:** [If possible]
```

---

## SUCCESS CRITERIA

**Week 1 is SUCCESS if:**
- ✅ First 60 seconds feels engaging
- ✅ 2 clicks to first egg
- ✅ First hatch = Rare (not Common)
- ✅ Click feedback (popup, sound)
- ✅ Passive income works
- ✅ Data saves between sessions
- ✅ No crashes or major bugs

**Target Fun Rating:** 7/10 or higher

---

## WHAT TO CHECK MANUALLY

### Critical (Must Work)
1. Coin popup appears on every click
2. Sound plays on click/hatch
3. First egg = Rare guaranteed
4. Pet idle animation (bounce/pulse)
5. Passive income display (+X/sec)
6. Data saves on exit

### Major (Should Work)
1. All 5 egg types can be bought
2. Hatching animation plays
3. Creature multiplier applies correctly
4. 10 clicks/second rate limit enforced
5. No console errors

### Minor (Nice to Have)
1. UI looks polished
2. All sounds distinct
3. Smooth animations
4. Mobile-friendly (if testing on phone)

---

## AFTER TESTING

**Report to me:**
1. Fun rating (1-10)
2. Any bugs found (use template above)
3. What feels good
4. What needs fixing

**Then:**
- Option B: Fix bugs → Re-test
- Option C: Proceed to Week 2 features
- Option D: Polish more before Week 2

---

## KNOWN LIMITATIONS (Not Bugs)

These are expected in Week 1:
- No creature 3D models (data only)
- No hatching animation sequence (instant reveal)
- No equip button (auto-equips first creature)
- No monetization yet
- No daily rewards
- No trading

These will be Week 2 features.

---

## BUILD LOCATION

`/data/.openclaw/workspace/CreatureClicker-Week1.rbxl`

**Size:** ~14 KB
**GitHub:** https://github.com/clawchin2/creature-clicker

Good luck testing! 🎮
