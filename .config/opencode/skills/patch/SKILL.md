---
name: patch
description: Lightweight patch loop for scoped changes (builder -> checker -> fixer, repeat checker/fixer until approved).
---

# Patch Workflow

## When to use

- Small-to-medium scoped changes on existing behavior/code paths.
- Bug fixes and targeted implementation updates.

## Do not use

- Broad redesigns or architecture-level rework.
- Multi-epic implementation programs.

## Role flow

1) builder (initial scoped change)
2) checker (review + validation)
3) fixer (targeted remediation)
4) checker <-> fixer repeat until checker approves

## Agent wiring

- Primary runner: `builder`
- Delegated roles: `checker`, `fixer`
- The runner should invoke delegated roles using the task tool and include the exact handoff format in each prompt.

## Rules

- Keep scope focused on existing behavior/code paths unless explicitly expanded.
- Fixer is remediation-only: local/mechanical fixes, no high-level redesign.
- If checker finds a functional gap that needs net-new implementation, route back to builder.
- Require checker to provide concrete findings with file paths and pass/fail evidence.
- Keep updates concise and show current phase + next role.

## Required handoff format

Use this exact structure for each role handoff:

ROLE: <builder|checker|fixer>
STATUS: <in_progress|blocked|ready_for_review|approved>
DONE:
- ...
NEXT:
- ...
BLOCKERS:
- none
ARTIFACTS:
- <paths/logs/commands>

## Completion criteria

- Checker reports no remaining blocking findings.
- Validation evidence is explicit (pass/fail, with commands or reason non-runnable).
- Scope remains within the user request.

## Guardrails

- Do not introduce unrelated refactors.
- Do not modify dependencies or build config unless explicitly requested.
- Do not weaken tests to force pass outcomes.
