---
name: patch
description: Unified patch loop for planned and ad-hoc implementation work.
---

# Patch Workflow

## Purpose

- Provide a patch-focused entrypoint for one scoped implementation slice.
- Keep patch work human-in-the-loop: implement, review, validate, then stop for user direction.

## When to use

- Small, targeted changes on existing behavior/code paths.
- Bug fixes and narrowly scoped implementation updates where the user wants control between slices.

## Do not use

- Broad redesigns or architecture-level rework.
- Multi-slice implementation runs that should continue autonomously.

## Role flow

1. implementer (initial scoped change)
2. reviewer_impl (review + scope validation)
3. fixer (targeted remediation)
4. reviewer_impl <-> fixer repeat until reviewer approves
5. qa validation
6. stop and hand back to the user

## Agent wiring

- Primary runner: `orchestrator`
- Entry behavior: single-slice patch loop
- Implementation role: `implementer`
- Delegation model:
  - Orchestrator routes implementer -> reviewer_impl -> qa across major phases.
  - Reviewer_impl and fixer can delegate to each other during the remediation loop.
  - Include the exact handoff format in each delegated prompt.
- Do not auto-route to committer unless the user explicitly asks for a commit after the patch loop finishes.
- If dispatcher support is unavailable, stop and surface the blocker instead of bypassing the orchestrated team workflow.

## Rules

- Keep scope to one logical slice and do not silently pull in adjacent backlog work.
- Keep scope focused on existing behavior/code paths unless explicitly expanded.
- Fixer is remediation-only: local/mechanical fixes, no high-level redesign.
- Reviewer_impl can delegate only to fixer, and fixer can delegate only to reviewer_impl.
- If reviewer finds a functional gap that needs net-new implementation, mark blocked and hand off to orchestrator for mediation/replanning.
- Require reviewer_impl to provide concrete findings with file paths and pass/fail evidence.
- After QA passes, stop and wait for the user instead of starting another slice or committing by default.
- Keep updates concise and show current phase + next role.

## Required handoff format

Use this exact structure for each role handoff:

ROLE: <implementer|reviewer_impl|fixer|qa>
STATUS: <in_progress|blocked|ready_for_review|ready_for_qa|ready_for_user>
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
- The current slice is ready for the user to review, request follow-up work, or hand off to committer separately.
- Scope remains within the user request.

## Guardrails

- Do not introduce unrelated refactors.
- Do not modify dependencies or build config unless explicitly requested.
- Do not weaken tests to force pass outcomes.
