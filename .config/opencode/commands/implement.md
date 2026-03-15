---
description: Unified build loop for planned or ad-hoc work
agent: orchestrator
subtask: true
---
Run Implement workflow for this request: `$ARGUMENTS`.

This command supports two intake modes:

1) planned mode
- Trigger when request references a design doc artifact (for example `@design-*.md`) or a beads epic/task with clear implementation metadata.
- Treat planned input as a multi-slice queue (DAG), not a single task.
- Required metadata per slice (from artifact/task):
  - slice id (unique),
  - task statement,
  - scope boundaries,
  - acceptance criteria,
  - proof commands with explicit pass signals,
  - dependencies (or none),
  - rollback note,
  - commit intent (`commit` or `no-commit-needed`).

2) ad-hoc mode
- Trigger when request is a direct change request without design artifact metadata.
- Before implementation, create a mini-plan with the same metadata fields above.
- If work is naturally multi-part, split ad-hoc work into executable slices before coding.

Mode resolution:
- If `$ARGUMENTS` is empty, first run artifact discovery in areas of interest (including `.opencode/` when present), suggest likely design artifacts, and return `NEEDS_USER_INPUT` so the parent can ask the user to select one before execution.
- If the user selects a discovered design artifact, run planned mode from that artifact metadata.
- Prefer planned mode when artifacts are present.
- If artifacts are partial/ambiguous, return `NEEDS_USER_INPUT` with one focused question only if needed to choose the next executable slice.
- Otherwise default to ad-hoc mode.

Execution budget and stopping:
- Execute multiple slices per invocation when dependencies allow.
- Default target budget is up to 10 successful slice cycles per invocation.
- If user explicitly provides a different limit in `$ARGUMENTS`, honor it.
- Do not try to exhaust all backlog items by default.
- Stop when:
  - budget is reached,
  - no dependency-ready slice remains,
  - a blocker requires user input,
  - or safety constraints prevent autonomous progress.

Per-slice loop (single unified execution engine):
1) orchestrator picks next dependency-ready slice
2) implementer
3) reviewer_impl
4) fixer when reviewer finds issues
5) reviewer_impl re-check
6) qa validation
7) implementer stages final relevant files for commit handoff
8) committer creates commit (or records no-commit-needed)
9) orchestrator closes slice-linked beads task only after committer outcome
10) return to step 1 for next ready slice until stop conditions are met

Loop rules:
- Repeat reviewer/fixer until reviewer approves.
- If QA fails, route to implementer for triage first; if remediation is narrow and concrete, delegate to fixer; then re-run reviewer + QA.
- Keep handoffs explicit with ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.
- Keep edits scoped to the selected task/slice boundaries.
- Do not expand scope without explicit user approval collected via parent-mediated `NEEDS_USER_INPUT`.
- During fixer steps, do not stage files; keep fixes unstaged for reviewer verification via unstaged diffs.
- During implementer steps, stage only files that are in-scope for the task using explicit paths (`git add <path>`), never broad `git add .`.
- Preserve dirty workspace safety: leave unrelated unstaged changes untouched and explicitly list excluded files in handoff notes.
- Before ending the workflow, ensure the intended commit contents are staged so the committer can focus on committing staged files only.
- Commit handoff is automatic by default: committer drafts and commits without user-message approval unless ambiguity/safety policy forces a blocker.
- For committer handoff in this workflow, set `MESSAGE_MODE: auto`.
- Do not close a beads task before committer completes.
- Beads task closure requires one of:
  - a commit hash from committer for the scoped task changes, or
  - explicit no-commit-needed evidence from committer (no file changes required), documented in handoff artifacts.
- If committer fails or is blocked, route back to implementer/fixer and keep the beads task open.

Scheduler rules for partially parallel plans:
- Respect declared dependencies; only execute slices whose dependencies are complete.
- If multiple independent slices are ready, keep commits serial and atomic (one slice per commit).
- Prefer high-impact ready slices first, then stable topological order.
- Record skipped/blocked slices with reason so a later `/implement` invocation can resume.

Quality gate:
- Run proof commands from planned artifact/mini-plan and report pass/fail evidence.
- For low-risk ad-hoc changes, allow light QA (targeted checks), but still provide explicit pass evidence.

Completion contract:
- End with a run report that includes:
  - completed slices + commit hashes,
  - slices closed with no-commit-needed evidence,
  - blocked or deferred slices,
  - clear resume point for next `/implement` run.

Treat this command as an orchestrator subtask entrypoint (`subtask: true`) with parent-mediated user interaction.
