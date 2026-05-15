---
name: post-session-learning
description: Use at the end of any significant session to capture learnings so future sessions on similar problems are faster and more automatic. Use when user says "wrap up", "capture learnings", "what should we save", or session is wrapping up. Also offer proactively after: debugging sessions that found a non-obvious solution, sessions where user stated a preference or corrected a pattern, sessions where a skill misbehaved, or sessions where a useful script was written. Goal: next time, Claude reaches the right answer without user having to nudge.
---

# Post-Session Learning Capture

Review the session and capture what would make a similar future session faster and more automatic — no user nudging required.

## Framing Question

For every exchange in the session, ask: **"Would this happen automatically next time, or would the user have to ask again?"**

If the user had to correct, redirect, repeat, or specify something that should be default behavior — that's a capture candidate.

## Analysis Process

Read the full conversation. For each friction point or non-obvious finding, determine:
1. What happened (the friction or discovery)
2. Why it matters for next time
3. Where to capture it (see routing below)
4. What the capture should say

Then present a structured proposal, get confirmation, execute.

---

## Capture Types and Routing

### User Preferences → AGENTS.md

**What to look for:**
- User stated a preference explicitly ("use X", "I prefer Y", "from now on Z")
- User corrected a pattern more than once
- User established a convention (fixture, helper, assertion style, import pattern)
- A preference was stated but not yet automatic

**Why capture it:** Next time, Claude applies the preference without being asked. User stops repeating themselves.

**Where to write it — pick narrowest applicable scope:**

| Applies to | Target |
|------------|--------|
| Any project, global default | `~/.claude/CLAUDE.md` |
| This project, all files | `<project-root>/AGENTS.md` |
| Specific subdirectory | `<dir>/AGENTS.md` |
| Tests only | `<project-root>/tests/AGENTS.md` |
| CI only | `.github/AGENTS.md` |

Example: "use hamcrest for assertions" → `tests/AGENTS.md`, not global. "use conventional commits" → project root `AGENTS.md`.

Write entries imperative, concise:
```markdown
## Testing

Use hamcrest for all assertions (`from hamcrest import assert_that, equal_to`).

Use `no_network` autouse fixture (defined in `tests/conftest.py`) in all tests. Blocks outbound HTTP. Do not mock requests manually.
```

---

### Debugging Solutions → `~/.agents/docs/solutions/`

**What to look for:**
- Root cause required non-obvious investigation
- Specific commands or checks revealed the problem
- A subtle system/framework/tool behavior was discovered
- Next time, same symptoms → same investigation path wasted

**Why capture it:** Future sessions skip the diagnostic loop and jump to the fix.

**How:** Run `/ce-compound` with context from the session. Write to `~/.agents/docs/solutions/<category>/` (create dir if needed). Categories: `debugging/`, `storage/`, `docker/`, `networking/`, `auth/`, `performance/`, `testing/`, `git/`, etc.

Format:
```markdown
---
module: docker
tags: [debugging, disk-space, build]
problem_type: environment
---

# Docker Build Failures: Disk Space

**Symptom:** Build fails mid-layer with obscure error.
**Diagnosis:** `df -h` shows /var/lib/docker full. `docker system df` shows breakdown.
**Fix:** `docker system prune -f`
**Next time:** Check `docker system df` first before investigating build errors.
```

---

### Scripts Written During Session → Version Control

**What to look for:**
- Any script created to diagnose, verify, migrate, or automate something
- Currently lives in `/tmp/`, was run inline, or only exists in the conversation
- Useful enough to run again or hand to someone else

**Why capture it:** Script gets reused instead of rewritten. Future sessions start with the tool already built.

**How:** Move to logical location in repo (`scripts/`, `tools/`, `bin/`). Commit and push. If script is general-purpose (not project-specific), consider `~/bin/`.

---

### Broken or Inadequate Skills → Fix the Skill

**What to look for:**
- A skill was invoked and its instructions were wrong, outdated, or incomplete
- Had to deviate significantly from what the skill said
- Skill caused wasted steps before the correction

**Why capture it:** Skill works correctly next time. No repeated deviation.

**How:** Locate the skill file. Apply a targeted fix — correct only what was wrong. Do not rewrite the whole skill unless the structure itself was the problem. Confirm with user before applying.

---

### Reusable Processes → New Skill Candidate

**What to look for:**
- Multi-step process was needed that isn't obvious or well-documented
- Process required iteration to discover
- Applies across projects, not just this one

**Why capture it:** Next time, the skill is invoked and the process is followed correctly from the start.

**How:** Flag it — propose using `/skill-creator` to formalize it. Don't auto-create; creating a skill requires proper testing.

---

## Proposal Format

Present before making any changes:

```
Here's what I found worth capturing:

PREFERENCES (→ AGENTS.md)
  [ ] Use hamcrest for Python test assertions
      → tests/AGENTS.md
      Next time: automatic, no prompting needed

  [ ] no_network autouse fixture blocks HTTP in all tests
      → tests/AGENTS.md
      Next time: fixture applied without being asked

SOLUTIONS (→ ~/.agents/docs/solutions/)
  [ ] Disk space check for Docker build failures
      → debugging/docker.md
      Next time: check df -h first, skip other investigation

SCRIPTS (→ version control)
  [ ] check-ports.sh — useful for port conflict debugging
      → scripts/check-ports.sh
      Next time: already exists, just run it

SKILL FIXES
  [ ] ce-compound had wrong solutions path — skipped writing to right dir
      → fix path in skill instructions

Anything to add, remove, or adjust scope on?
```

---

## If Nothing Worth Capturing

Say so briefly. Not every session produces captures. Don't manufacture entries.

## Execution Order

1. AGENTS.md entries (immediate behavior change, highest value)
2. Solutions docs (reference material)
3. Scripts (version control)
4. Skill fixes (targeted, surgical)
5. New skill proposals (flag only, don't create)
