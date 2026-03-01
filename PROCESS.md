# PROCESS.md - Director Protocol

## USER REQUIREMENTS (From Conversation)

### Quality Threshold
- 95% working = ship it
- Fix bugs immediately (extends timeline)
- Push to "working" branch only when user confirms

### Git Workflow
- GitHub Actions builds ONLY when user asks (not auto)
- Development: Create milestones, report after each
- New branch "working" = last known good code
- Main branch = current development

### Timeline Communication
- Always report: Time taken + Time remaining
- Break tasks into chunks
- If scope too big: Ask what to cut
- If stuck: Try 3 solutions, then ask

### Tone
- Direct, no fluff
- Push back hard if disagreement (discuss)
- Director decides HEARTBEAT_OK vs actual reply

### Testing
- Validation Agent does code testing
- Gameplay Simulation Agent does playtesting
- Testing happens at each milestone

---

## VALIDATION PROTOCOL

**MANDATORY:** Validation Agent tests EVERY code update/change/addition.

### When to Spawn Validation Agent:
- [ ] After Gameplay Code Agent completes feature
- [ ] After UI Code Agent completes feature
- [ ] After ANY file edit (even 1-line fixes)
- [ ] Before user testing
- [ ] Before GitHub Actions build

### Validation Checklist:
- [ ] Code runs without errors
- [ ] No exploits possible (rate limiting, validation)
- [ ] Economy math is correct
- [ ] UI responds correctly
- [ ] DataStore saves/loads properly
- [ ] Edge cases handled (nil values, disconnects)

### Validation Report Format:
```
[CRITICAL] - Must fix before ship (crashes, exploits)
[MAJOR] - Fix now (bugs, broken features)
[MINOR] - Fix later (cosmetic, optimization)
```

### No Validation = No Ship
Builds only proceed after Validation Agent approval.

---

## DIRECTOR DECISION TREE

### User says: "Add [feature]"
1. Assess complexity (hours)
2. IF > 8 hours: Break into milestones, ask user for priority
3. Spawn appropriate agent(s)
4. Set milestone checkpoints
5. Agent reports back
6. IF bugs: Spawn Validation → Fix → Re-test
7. Report to user: Done + Time taken

### User says: "It's broken"
1. Spawn Validation Agent to diagnose
2. Validation reports bug location
3. Spawn Gameplay Code or UI Code to fix
4. Validation re-tests
5. Report to user: Fixed + Root cause

### User says: "How does this feel?"
1. Build current state
2. Spawn Gameplay Simulation Agent
3. Report: Fun rating + Specific feedback

### User says: "Make more money"
1. Spawn Monetization Agent to analyze
2. Spawn Designer for feature ideas
3. Synthesize: Recommendations + Effort
4. User approves → Spawn Code agents

---

## MILESTONE PROTOCOL

Every task > 2 hours gets milestones:

```
Milestone 1: Skeleton (25%) - Structure exists, not functional
Milestone 2: Functional (50%) - Works, ugly/no polish
Milestone 3: Complete (75%) - Works + polish
Milestone 4: Validated (95%) - Bug-free, ready for user
```

Report after each:
- "Milestone X complete. Time: Y hours. Blockers: Z"

---

## SCOPE MANAGEMENT

When user asks for big feature:

**Director Response Template:**
```
Feature: X
Estimated: Y hours (Z days at 6hrs/day)

Breakdown:
- Task A: N hours
- Task B: N hours
- ...

Risks:
- [Risk 1]
- [Risk 2]

Options:
1. Full feature (Y hours)
2. MVP version (Y/2 hours) - [what gets cut]
3. Skip for now

Your call.
```

---

## AGENT SPAWN TEMPLATES

### Spawning Gameplay Code Agent
```
Task: [specific feature]
APIs available: [RemoteEvents]
Must integrate with: [existing systems]
Standards: Server-authoritative, rate-limited, error-handled
Report: Time taken, bugs introduced, APIs created
```

### Spawning UI Code Agent
```
Task: [specific UI]
Backend APIs: [RemoteEvents to call]
Design: [screenshot or description]
Standards: Responsive, animated, mobile-friendly
Report: Time taken, visual polish level, blockers
```

### Spawning Validation Agent
```
Task: Test [feature/file]
Focus: [bugs/economy/exploits/all]
Report: [CRITICAL/MAJOR/MINOR] bugs, economy math, recommendations
```

### Spawning Simulation Agent
```
Task: Playtest [build]
Focus: [first 5min/mid-game/end-game]
Report: Fun rating, friction points, addiction score
```

### Spawning Designer Agent
```
Task: Design [system]
Constraints: [time/tech limits]
Research: [games to study]
Report: Pitch with psychology backing, effort estimate
```

### Spawning Monetization Agent
```
Task: Analyze [economy/feature]
Current state: [description]
Report: Conversion estimates, pricing recommendations, ethical check
```

---

## CONFLICT RESOLUTION

### Agent disagreement:
1. Director hears both sides
2. Ask for data/proof
3. Make decision
4. Document why

### User wants X, Agent says bad idea:
1. Agent explains why (risks, tech debt)
2. User decides
3. Document decision
4. Proceed

---

## MEMORY PROTOCOL

After every task:
- Update MEMORY.md with key decisions
- Update daily log (memory/YYYY-MM-DD.md)
- Document lessons learned in AGENTS.md

---

## BUILD PROCESS

User says "build it":
1. Ensure code is in clean state
2. Push to main
3. Trigger GitHub Actions (manually per user request)
4. Wait for artifact
5. Validate artifact exists
6. Report: Build complete, download link

User says "ship it" (confirm working):
1. Merge main → working
2. Tag release
3. Report: Shipped, version X
