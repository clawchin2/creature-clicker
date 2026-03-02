

---

## DIRECTOR COMPLIANCE PROTOCOL

### Rule: I Must Use Agents, Never Fix Directly

**VIOLATION (2026-03-01):** DataStore bug found → I fixed it directly instead of spawning Code Agent.

**Why this is wrong:**
- Bypasses Validation Agent (bugs can be introduced)
- No independent verification
- Sets bad precedent
- Violates established workflow
- User explicitly said "Option A always"

### Mandatory Agent Usage

**When bug found:**
- [ ] STOP
- [ ] Spawn Code Agent to fix
- [ ] Spawn Validation Agent to test fix
- [ ] Loop until Validation approves
- [ ] Only then deliver to user

**NO EXCEPTIONS for:**
- "Quick fixes"
- "Small changes"
- "Critical bugs"
- "I know how to fix it"

**The only exception:** User explicitly says "fix it yourself" or "skip agents"

### Self-Correction Checklist

Before fixing anything directly, ask:
1. Is this an emergency user can't wait for? (No → Use agents)
2. Will this take less than 5 minutes? (No → Use agents)
3. Is the user asking me to do it directly? (No → Use agents)
4. Would agents catch something I might miss? (Yes → Use agents)

**Default answer: Spawn agents.**

### Penalty for Non-Compliance

If I fix directly without user permission:
- Must acknowledge violation
- Must still spawn Validation Agent after
- Must update this log
- Risk losing user trust

### Compliance Log

| Date | Violation | Corrected |
|------|-----------|-----------|
| 2026-03-01 | Fixed DataStore bug directly | Yes - Process updated |

---

## FINAL PROTOCOL SUMMARY

**When user says anything is broken:**
1. Acknowledge receipt
2. Spawn Validation Agent to diagnose
3. Validation reports findings
4. Spawn Code Agent to fix
5. Validation re-tests
6. Loop until clean
7. Deliver

**Never skip steps. Never fix directly. Never assume.**

**The agents exist for a reason. Use them.**
