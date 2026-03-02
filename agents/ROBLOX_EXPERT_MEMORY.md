# ROBLOX EXPERT AGENT - MEMORY

## ROLE
Find and curate Roblox free models, assets, sounds, images, and decals for games. Expert on Roblox Toolbox, Asset Library, and quality assessment.

## CORE PRINCIPLES
1. Free > Paid (for MVP)
2. Quality over quantity
3. Consistent art style
4. Performance matters (low poly preferred)
5. Mobile-friendly (simple meshes)

## ASSET SOURCES

### Primary: Roblox Toolbox
- Search keywords: "dragon free", "pet model", "creature", etc.
- Filter: Most favorited, Recently updated
- Check: Creator reputation, review comments

### Secondary: Roblox Asset Library
- Decals for 2D images
- Meshes for 3D models
- Audio for sounds

### Tertiary: Third-party (use with caution)
- Blender models → Roblox import
- Free3D.com (check licenses)
- Sketchfab (CC0 only)

## QUALITY CHECKLIST

### For 3D Models:
- [ ] Low poly (< 500 tris for pets)
- [ ] Single texture or vertex colors
- [ ] No external dependencies
- [ ] Properly scaled
- [ ] No scripts (unless needed)

### For 2D Images:
- [ ] Square aspect ratio (1:1)
- [ ] Minimum 256x256
- [ ] Transparent background (PNG)
- [ ] Cartoon style (matches Roblox aesthetic)

### For Sounds:
- [ ] Short (< 3 seconds for UI)
- [ ] Clear, not muddy
- [ ] No copyright issues

## SEARCH STRATEGIES

### Creature Types & Keywords:
| Creature | Search Terms |
|----------|--------------|
| Dragons | "dragon mesh", "dragon free", "cute dragon" |
| Wolves | "wolf mesh", "fox free", "canine" |
| Birds | "bird mesh", "phoenix free", "eagle" |
| Slimes | "slime mesh", "blob free", "cute monster" |
| Elementals | "fire elemental", "water spirit", "nature creature" |

### Style Modifiers:
- "low poly" - Better performance
- "cartoon" - Matches Roblox style
- "chibi" - Cute, appealing to kids
- "blocky" - Native Roblox look

## ASSET IDs (To Find/Verify)

### Creature Meshes (Need to find):
- Fire creatures (5 variants)
- Water creatures (5 variants)
- Earth creatures (5 variants)
- Air creatures (5 variants)
- Void creatures (5 variants)

### UI Elements:
- Coin icon
- Gem icon
- Egg icons (5 types)
- Button frames
- Particle textures

### Sounds:
- Click sound
- Coin get
- Hatch success
- Rare hatch
- Level up
- Error/buzzer

## CURATION LOG

### Found Assets:
- 2026-03-01: Comprehensive search strategy document created for 25 creatures
- Detailed search terms compiled for all 5 elements × 5 rarities
- Quality criteria and recoloring strategy documented
- Report saved to: creature_models_search_report.md

### Rejected Assets:
None yet.

### Asset ID Collection Status:
Direct web scraping of Roblox asset IDs not feasible due to:
- Roblox's anti-scraping measures
- Asset IDs not indexed by search engines
- Frequent asset availability changes

Recommended approach: Manual Toolbox search using provided keywords.

## BEST PRACTICES

1. **Always check comments** - Users report if broken/stolen
2. **Favor recent uploads** - Less likely to be broken
3. **Creator reputation** - Prefer established creators
4. **Test in Studio first** - Before adding to project
5. **Keep list organized** - By category, with IDs

## WORLD GEOMETRY CHECKLIST

**CRITICAL LESSON (2026-03-01):** Missing platform = broken game.

### Every Build Must Have:
- [ ] **Baseplate/Platform** - Player must have ground to stand on
- [ ] **SpawnLocation** - Positioned ABOVE the platform (not inside or below)
- [ ] **Lighting** - At least default lighting, not pitch black
- [ ] **Camera** - Reasonable default camera position

### Common World Setup Mistakes:
| Mistake | Result | Fix |
|---------|--------|-----|
| No platform | Player falls into void | Add Part named "Baseplate", size 100×1×100 |
| Spawn inside part | Player dies instantly | Move SpawnLocation 5 studs above platform |
| No lighting | Black screen | Verify Lighting service exists with default settings |
| Wrong spawn facing | Player looks at wall | Rotate SpawnLocation to face game area |

### Rojo project.json Workspace Check:
```json
"Workspace": {
  "$className": "Workspace",
  "SpawnLocation": { "$className": "SpawnLocation", "$properties": { "Position": [0, 10, 0] } },
  "Baseplate": {
    "$className": "Part",
    "$properties": {
      "Size": [100, 1, 100],
      "Position": [0, 0, 0],
      "Anchored": true
    }
  }
}
```

### Verification:
Before saying "world is ready":
1. Can a player spawn and stand still without falling?
2. Can they walk around (WASD)?
3. Is the camera facing the right direction?
4. Is anything obviously broken (floating parts, gaps)?

**Never assume world setup is correct. Always check.**

## DECISION LOG
- 2026-03-01: Agent created, assigned to find creature models for Creature Clicker
- 2026-03-01: Added world geometry checklist after platform bug discovered
