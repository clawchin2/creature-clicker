

---

## POST-MORTEM: Platform Bug (2026-03-01)

### What Happened
**Critical bug:** No platform/baseplate in Workspace. Player would spawn and fall into void.

**Why it was missed:**
- Validation Agent checked code/scripts only
- Gameplay Simulation Agent mentally simulated gameplay, didn't check workspace
- No agent verified world geometry exists
- default.project.json only had SpawnLocation, no floor

**Impact:** Game completely unplayable. Would fail immediately on test.

### Root Causes
1. **Validation scope too narrow** - Only checked Lua code, not project structure
2. **No world setup checklist** - Assumed basic environment existed
3. **Rojo project.json not validated** - Didn't verify workspace parts
4. **Simulation in head, not in Studio** - Agents can't "see" missing geometry

### Prevention (Added to PROCESS.md)

#### NEW: Pre-Build Checklist (Mandatory)
Before declaring "ready for testing":

**World Geometry:**
- [ ] SpawnLocation exists
- [ ] Baseplate/platform exists (player won't fall)
- [ ] SpawnLocation positioned above platform
- [ ] Lighting configured (not pitch black)
- [ ] Camera position reasonable

**Rojo Project.json:**
- [ ] All file paths valid
- [ ] Workspace has required parts
- [ ] StarterPlayer/StarterCharacterScripts configured
- [ ] ReplicatedStorage remotes defined

**Basic Playability:**
- [ ] Player can spawn without falling
- [ ] Player can move (WASD works)
- [ ] Camera follows player
- [ ] UI is visible (not obscured)

#### NEW: Validation Agent Expanded Scope
Validation Agent now checks:
1. Code functionality (existing)
2. **World geometry exists** (NEW)
3. **Rojo project.json validity** (NEW)
4. **Spawn/platform positioning** (NEW)

#### NEW: Build Verification Step
Before delivering build:
1. Run `rojo build` → Check for WARNINGS/ERRORS
2. Verify .rbxl file size > 5KB (empty world = ~3KB)
3. Mental check: "Can a player actually stand in this world?"

### Lesson Learned
**Simple != Obvious**
- Agents are code-focused
- Basic environment setup is invisible to code analysis
- Requires explicit checklist

### Updated Validation Checklist
```
- [ ] Code runs without errors
- [ ] No exploits possible
- [ ] Economy math correct
- [ ] UI responds correctly
- [ ] DataStore works
- [ ] WORLD: Platform exists (player won't fall)
- [ ] WORLD: SpawnLocation above platform
- [ ] WORLD: Lighting exists
- [ ] ROJO: project.json builds without errors
```

### Agent Memory Updates
- **Validation Agent:** Added world geometry checks
- **Gameplay Simulation:** Added "can player spawn" verification
- **All Agents:** Reminded that code != playable game

---

## LESSONS LEARNED

### 1. Code != Game
Working scripts don't mean working game. Need world, lighting, camera, spawn.

### 2. Agents Need Checklists
Smart agents miss obvious things. Explicit checklists prevent "assumption blindness."

### 3. Build Before Declare
Always run `rojo build` before saying "done." Catches missing files/parts.

### 4. Simple Bugs Kill
No platform = game over. Takes 30 seconds to add, hours to discover without checklist.

### 5. User Catches What Agents Miss
You caught this. Validation protocol now includes user verification as final step.

---

## UPDATED AGENT PROMPTS

### Validation Agent Now Gets:
```
TASK: Test code AND world setup

CHECK:
- [ ] All scripts run
- [ ] No errors
- [ ] WORLD: SpawnLocation exists
- [ ] WORLD: Platform/Baseplate exists
- [ ] WORLD: Spawn above platform
- [ ] ROJO: project.json builds
- [ ] BUILD: .rbxl generates without errors

FAIL if any world check fails.
```

### Gameplay Simulation Agent Now Gets:
```
TASK: Simulate playthrough

SCENARIO 1: Spawn Test
- Player spawns → Do they fall? Can they move?
- Check: "Player stands on platform, not void"

SCENARIO 2: Gameplay loop...
```

---

## FINAL CHECKLIST (Every Build)

**Code:**
- [ ] No syntax errors
- [ ] No runtime errors
- [ ] DataStore works

**World:**
- [ ] Platform exists
- [ ] SpawnLocation exists
- [ ] Lighting exists
- [ ] Player can stand

**Build:**
- [ ] Rojo builds without errors
- [ ] .rbxl file > 5KB
- [ ] Can open in Studio

**Play:**
- [ ] Spawn works
- [ ] Movement works
- [ ] UI visible
- [ ] Core loop functional

---

**This prevents "platform bug" from happening again.**
