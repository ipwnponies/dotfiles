---
description: Unified build loop for planned or ad-hoc work
agent: orchestrator
subtask: true
---
Run Implement workflow for this request: `$ARGUMENTS`.

Skill-based entrypoint usage:
- This command is the deterministic subtask target for the `implement` skill.
- When launched from `implement` with empty `$ARGUMENTS`, parent should pass the required prompt envelope exactly once in the initial orchestrator task prompt.
- For follow-up `NEEDS_USER_INPUT` turns, parent should resume the same task via `task_id` and include user replies plus updated constraints.

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
- If `$ARGUMENTS` is empty, run **intent discovery** first:
  - Inspect recent conversation context (prior user/assistant turns in this session) for implementation-ready intent.
  - Because this command runs with `subtask: true`, treat "recent conversation context" as parent-supplied context included in the task prompt and/or resumed `task_id` session state.
  - Do not assume direct access to the full parent chat transcript unless that context is explicitly provided by the parent.
  - Prioritize explicit user confirmations and assistant implementation offers (for example: "I can implement X and Y").
  - Extract candidate intents as short actionable statements; keep only candidates that are specific enough to execute.
  - Then run artifact discovery in areas of interest (including `.opencode/` when present) and gather relevant beads tasks.
  - Merge results into one shortlist and return `NEEDS_USER_INPUT` so the parent can ask the user to choose what to execute.
  - If one candidate is clearly dominant (most recent + explicit + scoped), present it as the recommended default in the `NEEDS_USER_INPUT` prompt.
- If the user selects a discovered design artifact, run planned mode from that artifact metadata.
- Prefer planned mode when artifacts are present.
- If artifacts are partial/ambiguous, return `NEEDS_USER_INPUT` with one focused question only if needed to choose the next executable slice.
- Otherwise default to ad-hoc mode.

Intent discovery protocol (used when `$ARGUMENTS` is empty):
- Build candidates from three sources: (1) parent-supplied recent chat intent, (2) discovered design artifacts, (3) dependency-ready beads work.
- Do not treat vague brainstorming as executable intent unless it includes a concrete change target and success shape.
- If chat intent references files/components that match discovered artifacts/tasks, link them as one candidate instead of duplicating options.
- Ask exactly one user-facing selection question with a concise option list plus "Type your own" fallback.
- Preserve existing behavior conditionally: if no reliable parent-supplied chat intent is found, proceed with artifact/beads discovery-only selection flow only when the required prompt envelope is present/substantive or prior user confirmation to artifact-only discovery already exists in resumed context.

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
7) committer stages from finalized STAGE_MANIFEST and creates commit (or records no-commit-needed)
8) orchestrator closes slice-linked beads task only after committer outcome
9) return to step 1 for next ready slice until stop conditions are met

Loop rules:
- Repeat reviewer/fixer until reviewer approves and marks STAGE_MANIFEST as final.
- If QA fails, route to implementer for triage first; if remediation is narrow and concrete, delegate to fixer; then re-run reviewer + QA.
- Keep handoffs explicit with ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.
- Keep edits scoped to the selected task/slice boundaries.
- Do not expand scope without explicit user approval collected via parent-mediated `NEEDS_USER_INPUT`.
- During fixer steps, do not stage files; keep fixes unstaged for reviewer verification via unstaged diffs, and update candidate STAGE_MANIFEST paths as edits change.
- During implementer steps, maintain candidate STAGE_MANIFEST (`include` + `exclude`) for in-scope files; do not run `git commit`.
- During reviewer steps, validate scope and mark STAGE_MANIFEST as final before QA.
- On QA pass, orchestrator hands finalized STAGE_MANIFEST directly to committer; do not route back to implementer unless QA failed.
- During committer steps, stage only manifest `include` paths with explicit `git add <path>` and verify manifest `exclude` paths stay unstaged.
- Preserve dirty workspace safety: leave unrelated unstaged changes untouched and explicitly list excluded files in handoff notes.
- Before ending the workflow, ensure finalized STAGE_MANIFEST is explicit and committer-validated against the staged index.
- Commit handoff is automatic by default: committer drafts and commits without user-message approval unless ambiguity/safety policy forces a blocker.
- For committer handoff in this workflow, set `MESSAGE_MODE: auto`.
- Do not close a beads task before committer completes.
- Beads task closure requires one of:
  - a commit hash from committer for the scoped task changes, or
  - explicit no-commit-needed evidence from committer (no file changes required), documented in handoff artifacts.
- If committer fails or is blocked on scope/manifest mismatch, route to reviewer_impl for manifest correction; if blocked on code defects, route to implementer/fixer; keep the beads task open.

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

Parent context contract (only needed when implementation intent is inferred from conversation):
- If `$ARGUMENTS` already contains explicit implementation intent (for example artifact/task references or direct executable scope), parent context is optional.
- When intent is inferred from conversation (typically empty `$ARGUMENTS`), parent should include a concise "Recent conversation context" block in the task prompt with the latest user ask, constraints, and approvals.
- For every `NEEDS_USER_INPUT` turn, parent should ask the user, then resume the same task via `task_id` and include the user's reply (plus any updated constraints/decisions).
- Required prompt envelope for inferred-intent mode (empty `$ARGUMENTS`):
  - `Recent conversation context:`
  - `Inferred build intent:`
  - `Constraints and approvals:`
- If `$ARGUMENTS` is empty and the required prompt envelope is missing or substantially empty, return `NEEDS_USER_INPUT` asking for either:
  - a one-line explicit build/implementation intent, or
  - confirmation to proceed with artifact-only discovery.
- Do not infer implementation intent from unstated/implicit chat history in this fail-safe branch.

Treat this command as an orchestrator subtask entrypoint (`subtask: true`) with parent-mediated user interaction.
