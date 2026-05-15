---
name: post-session-learning
description: Use at the end of any significant session, or proactively when a session is wrapping up. Retrospectively scans the conversation for knowledge worth preserving and routes each finding to the right destination. Use when the user says "wrap up", "capture learnings", "save what we learned", "what should we document", or when a session resolved a non-obvious bug, established a preference, produced a useful script, or invoked a skill that failed. Always offer to run this at the end of debugging sessions, implementation sessions, or when the user states a preference or pattern they want automatic in the future.
---

# Post-Session Learning Capture

Scan the session for durable knowledge and route each finding to the right place. The goal: next time a similar situation arises, the solution is already there — without the user having to ask.

## Categories to Scan For

### 1. Debugging Solutions → `~/.agents/docs/solutions/`

Non-obvious technical findings worth future reference.

**Signals in conversation:**
- A bug was resolved with a non-obvious approach
- A specific command or check revealed the root cause (e.g., `df -h`, `dmesg`, inspecting a specific config)
- A subtle system or framework behavior was discovered
- A workaround was found for a known tool limitation

**Action:** Use the `/ce-compound` skill to write a solution doc to `~/.agents/docs/solutions/<category>/`. Categories: `debugging/`, `storage/`, `networking/`, `auth/`, `docker/`, `performance/`, `testing/`, `git/`, etc.

---

### 2. User Preferences and Conventions → AGENTS.md

Preferences or patterns the user stated, corrected toward, or established during the session.

**Signals:**
- "I want to always use X"
- "from now on, use Y"
- "let's establish a pattern of Z"
- "use hamcrest / pytest-mock / etc."
- User corrected the same pattern more than once
- User explicitly set a convention (fixture, helper, import style, etc.)

**Scope routing — pick the narrowest scope that applies:**

| Preference type | Target |
|----------------|--------|
| Applies everywhere, any project | `~/.claude/CLAUDE.md` |
| Project-wide (any file in repo) | `<project-root>/AGENTS.md` |
| Specific subdirectory only | `<dir>/AGENTS.md` |
| Tests only | `<project-root>/tests/AGENTS.md` |
| CI/GitHub Actions only | `.github/AGENTS.md` |

When in doubt, scope narrower. Global AGENTS.md accumulates noise fast.

**Format for entries — imperative, concise:**
```markdown
## Testing

Use hamcrest for all assertions (`from hamcrest import assert_that, equal_to`).

Use the `no_network` autouse fixture (defined in `tests/conftest.py`) in all tests. It blocks outbound HTTP. Do not mock requests manually.
```

---

### 3. Broken or Inadequate Skills → Fix the Skill

If a skill was invoked and produced wrong output, had incorrect steps, or had to be significantly deviated from.

**Signals:**
- Skill was loaded but its instructions were wrong, outdated, or incomplete
- Had to override or correct the skill's guidance
- Skill caused wasted effort before the correction was made

**Action:** Locate the skill file, identify the specific flaw, propose a targeted fix. Apply with user approval. Do not rewrite — surgical correction only.

---

### 4. Scripts Written During Session → Check Into Version Control

Any scripts created during the session that are useful beyond it.

**Signals:**
- A script was written to diagnose, verify, migrate, or automate something
- It currently lives in `/tmp/`, inline in the conversation, or was run once and discarded
- It would be useful to run again or adapt later

**Action:** Move to a logical permanent location (`scripts/`, `tools/`, `bin/`). Commit and push. If the session is in a repo, check it into the appropriate location there.

---

### 5. Reusable Multi-Step Processes → New Skill Candidate

Processes discovered during the session that will recur across projects or contexts.

**Signals:**
- Followed a multi-step diagnostic or setup process that wasn't obvious
- Process required iteration to discover and would take similar effort next time
- Would apply in different projects or contexts

**Action:** Flag as a skill candidate for the user. Do not auto-create. Propose using `/skill-creator` to capture it.

---

## Process

### Step 1: Scan

Read the conversation top to bottom. For each category above, note:
- What was found
- Which destination it should go to
- What the entry would say

### Step 2: Propose

Present a structured summary to the user **before making any changes**:

```
Here's what I found worth capturing from this session:

SOLUTIONS (→ ~/.agents/docs/solutions/)
  [ ] Docker build failure: disk space check pattern
      → debugging/docker.md

PREFERENCES (→ AGENTS.md)
  [ ] Use hamcrest for Python test assertions
      → tests/AGENTS.md
  [ ] no_network autouse fixture to block outbound HTTP in tests
      → tests/AGENTS.md

SCRIPTS (→ version control)
  [ ] check-ports.sh written during session
      → move to scripts/check-ports.sh, commit

SKILLS (fix or create)
  [ ] ce-compound had wrong solutions path in instructions — fix it
  [ ] New skill candidate: diagnosing container networking issues

Anything to add, remove, or adjust?
```

Do not execute until the user confirms. If they adjust the list, update accordingly.

### Step 3: Execute

For each approved item, in order:
- **Solutions:** run `/ce-compound` with the relevant context, writing to `~/.agents/docs/solutions/`
- **AGENTS.md:** write or append the entry at the correct scope level
- **Scripts:** move file, `git add`, `git commit`, `git push`
- **Skill fixes:** apply surgical edits to the skill file
- **New skill candidates:** open a conversation with `/skill-creator`

### Step 4: Confirm

After all captures are done, report what was written and where.

---

## If Nothing Worth Capturing Is Found

Say so briefly. Not every session produces durable learnings. Don't manufacture entries.

---

## Writing Solutions Docs (ce-compound format)

```markdown
---
module: docker
tags: [debugging, disk-space, build]
problem_type: environment
---

# Docker Build Failures: Disk Space

**Symptom:** Build fails mid-layer with an obscure error.
**Diagnosis:** `df -h` shows /var/lib/docker at capacity. `docker system df` shows breakdown by type.
**Fix:** `docker system prune -f` reclaims space from stopped containers and dangling images.
**Prevention:** Check `docker system df` before large builds or in CI if storage is constrained.
```

Categories map to `~/.agents/docs/solutions/<category>/`. Create the directory if it doesn't exist.
