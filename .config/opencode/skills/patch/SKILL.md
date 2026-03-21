---
name: patch
description: Straightforward mechanical changes where you know exactly what to do. Use when the fix is obvious - just tedious. For work requiring thinking/planning, use /implement instead.
---

# Patch Workflow

## When to use

**Use `/patch` when you know exactly what needs to change:**
- "Add dry run flag to function_foo"
- "Fix typo in all error messages"
- "Add logging to database queries"
- "Convert print() to logger.info()"
- Simple bug fixes with obvious solutions
- Mechanical refactors following a clear pattern

**Key indicators:**
- The fix is straightforward - just tedious to do manually
- No architectural decisions needed
- Single approach is obvious

## Do NOT use - use `/implement` instead when:

- "Figure out how to add caching" (needs architectural thinking)
- "Implement rate limiting" (multiple approaches to consider)
- "Add authentication" (requires design decisions)
- Work from design docs or beads epics
- Multi-slice work with dependencies
- Broad redesigns or architecture-level rework

## Role flow

1. implementer (initial scoped change)
2. reviewer_impl (review + validation)
3. fixer (targeted remediation)
4. reviewer_impl <-> fixer repeat until reviewer approves
5. qa validation
6. **Stop - user reviews changes and commits interactively**

## Agent wiring

- Primary runner: `orchestrator`
- Implementation role: `implementer` (no delegation)
- Delegation model:
  - Orchestrator routes implementer -> reviewer_impl -> qa across major phases.
  - Reviewer_impl and fixer can delegate to each other during the remediation loop.
  - After QA completes, orchestrator stops (no committer handoff).
- Include the exact handoff format in each delegated prompt.

## Rules

- Keep scope focused on existing behavior/code paths unless explicitly expanded.
- Fixer is remediation-only: local/mechanical fixes, no high-level redesign.
- Reviewer_impl can delegate only to fixer, and fixer can delegate only to reviewer_impl.
- If reviewer finds a functional gap that needs net-new implementation, mark blocked and hand off to orchestrator for mediation/replanning.
- Require reviewer_impl to provide concrete findings with file paths and pass/fail evidence.
- Keep updates concise and show current phase + next role.

## Required handoff format

Use this exact structure for each role handoff:

ROLE: <implementer|reviewer_impl|fixer|qa>
STATUS: <in_progress|blocked|ready_for_review|ready_for_qa|approved>
DONE:
- ...
NEXT:
- ...
BLOCKERS:
- none
ARTIFACTS:
- <paths/logs/commands>

## Completion criteria

- Reviewer_impl reports no remaining blocking findings.
- QA reports explicit pass evidence (commands + pass signal).
- Scope remains within the user request.
- **Changes left unstaged for user to review and commit interactively.**

## Guardrails

- Do not introduce unrelated refactors.
- Do not modify dependencies or build config unless explicitly requested.
- Do not weaken tests to force pass outcomes.
