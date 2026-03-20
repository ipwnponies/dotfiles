---
name: patch
description: Unified patch loop for planned and ad-hoc implementation work.
---

# Patch Workflow

## When to use

- Small-to-medium scoped changes on existing behavior/code paths.
- Bug fixes and targeted implementation updates.

## Do not use

- Broad redesigns or architecture-level rework.
- Multi-epic implementation programs.

## Role flow

1. implementer (initial scoped change)
2. reviewer_impl (review + validation)
3. fixer (targeted remediation)
4. reviewer_impl <-> fixer repeat until reviewer approves
5. qa validation
6. committer handoff and commit result

## Agent wiring

- Primary runner: `orchestrator`
- Implementation role: `implementer` (no delegation)
- Delegation model:
  - Orchestrator routes implementer -> reviewer_impl -> qa across major phases.
  - Reviewer_impl and fixer can delegate to each other during the remediation loop.
  - Researcher and reviewer can delegate to each other during design-phase review loops.
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

ROLE: <implementer|reviewer_impl|fixer|qa|committer>
STATUS: <in_progress|blocked|ready_for_review|ready_for_commit|ready_for_qa|ready_to_close>
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
- Committer reports commit hash (or explicit no-commit-needed evidence).
- Scope remains within the user request.

## Guardrails

- Do not introduce unrelated refactors.
- Do not modify dependencies or build config unless explicitly requested.
- Do not weaken tests to force pass outcomes.
