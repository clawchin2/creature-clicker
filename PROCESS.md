

---

## CORE FIRST, POLISH LATER STANDARD

**Established: 2026-03-02**

**User Directive:** "Build core functionality first, then add everything else"

### Implementation Order

**1. CORE FUNCTIONALITY**
Build minimum viable feature that WORKS:
- Click button → Earn coins ✓
- Buy egg → Get creature instantly (no animation yet)
- Basic UI elements (functional, not pretty)

**2. VERIFY CORE**
- Spawn Validation Agent
- Confirm functionality works
- Fix any bugs before adding complexity

**3. ADD POLISH**
Only after core verified:
- Animations
- Sound effects
- Visual flair
- Particle effects
- Complex UI transitions

### Why This Works

- Faster iterations (less agent timeout)
- Working game at each milestone
- Easier debugging (smaller scope)
- Clear progress visible
- Less wasted API credits

### Example Sequence

**Week 1: Clicker Core**
- Day 1-2: Click → Earn coins (CORE) ✅
- Day 3-4: Polish (animations, sounds)

**Week 2: Hatching Core**
- Day 1-2: Buy egg → Get creature (CORE)
- Day 3-4: Polish (hatch animations)

**Week 3: Monetization Core**
- Day 1-2: Gamepass works (CORE)
- Day 3-4: Polish (shop UI, effects)

### Agent Task Guidelines

**CORE Task (Good):**
"Create Buy Egg button. When clicked: deduct coins, give random creature, show in inventory."

**POLISH Task (After Core Works):**
"Add egg hatching animation: shake 2s, crack effect, creature reveal with rarity glow."

### Never Do

❌ Complex UI with animations before basic button works
❌ Full feature set in one agent task  
❌ Polish before core functionality verified
❌ "Build everything at once"

### Always Do

✅ Smallest working version first
✅ Validate before adding complexity
✅ One core feature per agent cycle
✅ "Make it work, then make it pretty"

---
