---
description: Unified build loop for planned or ad-hoc work
agent: orchestrator
subtask: true
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
- If `$ARGUMENTS` is empty, first run artifact discovery in areas of interest (including `.opencode/` when present), suggest likely design artifacts, and return `NEEDS_USER_INPUT` so the parent can ask the user to select one before execution.
- If the user selects a discovered design artifact, run planned mode from that artifact metadata.
- Prefer planned mode when artifacts are present.
- If artifacts are partial/ambiguous, return `NEEDS_USER_INPUT` with one focused question only if needed to choose the next executable slice.
- Otherwise default to ad-hoc mode.

Team loop (single unified execution engine):
1) implementer
2) reviewer_impl
3) fixer when reviewer finds issues
4) reviewer_impl re-check
5) qa validation
6) implementer stages final relevant files for commit handoff
7) committer creates commit (or records no-commit-needed)
8) orchestrator closes the beads task only after committer outcome

Loop rules:
- Repeat reviewer/fixer until reviewer approves.
- If QA fails, route to implementer/fixer and re-run review + QA.
- Keep handoffs explicit with ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.
- Keep edits scoped to the selected task/slice boundaries.
- Do not expand scope without explicit user approval collected via parent-mediated `NEEDS_USER_INPUT`.
- During fixer steps, do not stage files; keep fixes unstaged for reviewer verification via unstaged diffs.
- During implementer steps, stage only files that are in-scope for the task using explicit paths (`git add <path>`), never broad `git add .`.
- Preserve dirty workspace safety: leave unrelated unstaged changes untouched and explicitly list excluded files in handoff notes.
- Before ending the workflow, ensure the intended commit contents are staged so the committer can focus on committing staged files only.
- Do not close a beads task before committer completes.
- Beads task closure requires one of:
  - a commit hash from committer for the scoped task changes, or
  - explicit no-commit-needed evidence from committer (no file changes required), documented in handoff artifacts.
- If committer fails or is blocked, route back to implementer/fixer and keep the beads task open.

Quality gate:
- Run proof commands from planned artifact/mini-plan and report pass/fail evidence.
- For low-risk ad-hoc changes, allow light QA (targeted checks), but still provide explicit pass evidence.

Treat this command as an orchestrator subtask entrypoint (`subtask: true`) with parent-mediated user interaction.
