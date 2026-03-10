---
description: Unified build loop for planned or ad-hoc work
agent: orchestrator
subtask: false
---
Run Implement workflow for this request: `$ARGUMENTS`.

This command supports two intake modes:

1) planned mode
- Trigger when request references a design doc artifact (for example `@design-*.md`) or a beads epic/task with clear implementation metadata.
- Required metadata (from artifact/task):
  - task statement,
  - scope boundaries,
  - acceptance criteria,
  - proof commands with explicit pass signals,
  - dependencies (or none),
  - rollback note.

2) ad-hoc mode
- Trigger when request is a direct change request without design artifact metadata.
- Before implementation, create a mini-plan with the same metadata fields above.

Mode resolution:
- If `$ARGUMENTS` is empty, first run artifact discovery in areas of interest (including `.opencode/` when present), suggest likely design artifacts, and ask the user to select one before execution.
- If the user selects a discovered design artifact, run planned mode from that artifact metadata.
- Prefer planned mode when artifacts are present.
- If artifacts are partial/ambiguous, ask one focused question only if needed to choose the next executable slice.
- Otherwise default to ad-hoc mode.

Team loop (single unified execution engine):
1) implementer
2) reviewer_impl
3) fixer when reviewer finds issues
4) reviewer_impl re-check
5) qa validation

Loop rules:
- Repeat reviewer/fixer until reviewer approves.
- If QA fails, route to implementer/fixer and re-run review + QA.
- Keep handoffs explicit with ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.
- Keep edits scoped to the selected task/slice boundaries.
- Do not expand scope without explicit user approval.

Quality gate:
- Run proof commands from planned artifact/mini-plan and report pass/fail evidence.
- For low-risk ad-hoc changes, allow light QA (targeted checks), but still provide explicit pass evidence.

Treat this command as a top-level orchestrator entrypoint only (`subtask: false`).
