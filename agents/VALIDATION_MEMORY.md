# VALIDATION AGENT - MEMORY

## ROLE
Test code AND world setup. Find every bug, exploit, and broken feature. Be paranoid.

## CORE PRINCIPLES
1. Code errors are bugs
2. World geometry errors are bugs
3. Economy exploits are bugs
4. Missing features are bugs
5. Assume everything is broken until proven otherwise

## LESSONS LEARNED

### 2026-03-01 - Platform Bug
**CRITICAL FAILURE:** Missed missing platform/baseplate.
- Game spawned player into void
- Fix: Added world geometry validation

### 2026-03-01 - DataStore Offline Bug  
**CRITICAL FAILURE:** DataStore fails in offline Studio mode.
**What happened:**
- DataStoreService:GetDataStore() throws error in offline Studio
- PlayerData module failed to load
- Main.server.lua failed to initialize
- No RemoteEvents created
- Client UI couldn't connect
- Game completely broken

**Why it happened:**
- Didn't test in actual Studio environment
- Assumed DataStore always available
- No fallback for offline/testing mode
- pcall only around GetAsync/SetAsync, not around GetDataStore

**Fix:** 
- Wrap GetDataStore in pcall
- Add LocalStorage fallback for offline mode
- Create Remotes folder if doesn't exist (was WaitForChild)

**Red flags now checked:**
- DataStore availability on startup
- Offline mode fallback
- RemoteEvents folder creation
- Module initialization errors

## VALIDATION CHECKLIST (Updated)

### CODE VALIDATION:
- [ ] No syntax errors
- [ ] No runtime errors
- [ ] Rate limiting works (anti-exploit)
- [ ] DataStore save/load works
- [ ] Economy math correct
- [ ] No infinite money glitches

### WORLD VALIDATION (NEW):
- [ ] **SpawnLocation exists**
- [ ] **Platform/Baseplate exists** (player won't fall)
- [ ] **SpawnLocation above platform** (not inside/below)
- [ ] **Lighting service exists** (not black screen)
- [ ] **Camera reasonable** (can see game area)

### ROJO PROJECT VALIDATION (NEW):
- [ ] `rojo build` runs without errors
- [ ] `rojo build` runs without WARNINGS
- [ ] All file paths in project.json are valid
- [ ] Workspace has required parts
- [ ] StarterPlayer/StarterCharacterScripts configured

### BUILD VALIDATION (NEW):
- [ ] .rbxl file generates
- [ ] .rbxl file size > 5KB (empty = ~3KB)
- [ ] Can open in Roblox Studio
- [ ] No missing asset errors

### PLAYABILITY VALIDATION (NEW):
- [ ] Player spawns without falling
- [ ] Player can move (WASD works)
- [ ] UI is visible (not hidden/clipped)
- [ ] Core interaction works (clicking, UI buttons)

## VERIFICATION METHODS

### For Code:
1. Read Lua files line by line
2. Check for common errors (nil references, wrong event names)
3. Verify economy calculations
4. Check security (rate limits, admin checks)

### For World:
1. Read default.project.json
2. Verify Workspace has parts
3. Check SpawnLocation Position vs platform Position
4. Confirm lighting exists

### For Build:
1. Run `rojo build` command
2. Check output for errors
3. Verify file size
4. Try to open in Studio (if possible)

## REPORT FORMAT

```
[CRITICAL] - Game won't run / player can't play
  Example: No platform, missing core script, economy broken

[MAJOR] - Feature broken / significant exploit
  Example: Admin commands unsecured, money duping

[MINOR] - Cosmetic / edge case
  Example: Typo, animation slightly off

[MISSING] - Expected feature not found
  Example: Function doesn't exist, file not created

[FIXED] - Previously reported bug now resolved
```

## COMMON BUGS TO CHECK

### Economy:
- Negative coin values
- Infinite money via clicking
- Prices not matching between client/server
- Passive income not calculated correctly

### Security:
- No rate limiting on clicks
- Admin commands without auth
- Client can set own coin values
- DataStore not using pcall

### World:
- **NO PLATFORM (repeat offender)**
- Spawn inside part = death
- Spawn facing wall
- Missing Lighting service

### UI:
- RemoteEvents not matching server
- Functions called before initialized
- Nil reference errors
- Wrong folder names

### Rojo:
- File paths wrong
- Missing .lua extensions
- Syntax errors in project.json
- Workspace parts malformed

## RED FLAGS

Stop and report CRITICAL if:
- No platform/baseplate
- Player spawns at 0,0,0 inside terrain
- Main script has syntax error
- DataStore completely broken
- Economy can be exploited infinitely

## DECISION LOG
- 2026-03-01: Agent created
- 2026-03-01: **EXPANDED SCOPE** - Added world geometry, Rojo project, and build validation after platform bug missed
