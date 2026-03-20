---
description: Design research flow (researcher <-> reviewer, researcher writes artifacts, orchestrator coordinates, user approval gate)
agent: orchestrator
subtask: true
---
Run the Design workflow for this request: `$ARGUMENTS`.

This command is design-only. Do not implement code changes.

Skill-based entrypoint usage:
- This command is the deterministic subtask target for the `design` skill.
- When launched from `design` with empty `$ARGUMENTS`, parent should pass the required prompt envelope exactly once in the initial orchestrator task prompt.
- For follow-up `NEEDS_USER_INPUT` turns, parent should resume the same task via `task_id` and include user replies plus updated constraints.

Intake and intent discovery:
- If `$ARGUMENTS` is empty, run **design intent discovery** first:
  - Inspect recent conversation context (prior user/assistant turns in this session) for design-ready intent.
  - Because this command runs with `subtask: true`, treat "recent conversation context" as parent-supplied context included in the task prompt and/or resumed `task_id` session state.
  - Do not assume direct access to the full parent chat transcript unless that context is explicitly provided by the parent.
  - Prioritize explicit user confirmations and assistant design/research offers (for example: "I can research and design X").
  - Extract candidate intents as short designable problem statements; keep only candidates with concrete scope and success shape.
  - Return `NEEDS_USER_INPUT` so the parent can ask the user to confirm which inferred chat intent to design.
  - If one candidate is clearly dominant (most recent + explicit + scoped), present it as the recommended default in the `NEEDS_USER_INPUT` prompt.
- If `$ARGUMENTS` is provided, use it as the design intent directly.

Intent discovery protocol (used when `$ARGUMENTS` is empty):
- Build candidates from parent-supplied recent chat intent only.
- Vague brainstorming is allowed as design direction; normalize it into a best-effort candidate intent for user confirmation.
- Normalize candidate wording into one-sentence "Design X for Y" statements the user can quickly select.
- Ask exactly one user-facing selection question with concise options plus a "Type your own" fallback.
- If no reliable parent-supplied chat intent is found, return `NEEDS_USER_INPUT` asking the user to provide a one-line design intent.

Parent context contract:
- Do not rely on one-line context summaries when prior discussion exists.
- If prior discussion exists (including a single long turn), parent must include a structured context packet in the initial prompt, even when `$ARGUMENTS` contains explicit design intent.
- For each `NEEDS_USER_INPUT` turn, parent should resume the same task via `task_id` and include the user's reply plus any updated constraints/decisions/context packet fields.
- If no parent-supplied conversation context is available, ask one targeted intent-selection/intent-capture question instead of assuming chat intent.

Required prompt envelope for inferred-intent mode (empty `$ARGUMENTS`):
- The parent-provided task prompt should include these labeled sections:
  - `Recent conversation context:`
  - `Current user intent:`
  - `Inferred design intent:`
  - `Decisions made:`
  - `Constraints and approvals:`
  - `Open questions and risks:`
  - `Referenced artifacts:`
- Coverage guidance:
  - Include the right amount of detail to preserve intent and constraints; do not force fixed minimums or maximums.
  - `Recent conversation context:` retain enough detail to avoid compressing materially important discussion into one line.
  - `Decisions made:` include accepted and rejected options when applicable.
  - `Constraints and approvals:` include explicit safety/tool/network approvals or denials when present.
- If these sections are missing or substantially empty, treat context as unavailable.

Required prompt envelope for explicit-intent mode (non-empty `$ARGUMENTS`) when prior discussion exists:
- Include all sections except `Inferred design intent:`.
- If prior discussion exists but packet coverage is too shallow to preserve intent/constraints, return `NEEDS_USER_INPUT` requesting a fuller context packet before continuing.

Fail-safe when context envelope is missing:
- If required prompt-envelope context is unavailable in inferred-intent mode, return `NEEDS_USER_INPUT` asking for either:
  - a one-line explicit design intent, or
  - confirmation to proceed with artifact-only discovery.
- If explicit intent is provided but prior discussion exists and packet coverage is too shallow, return `NEEDS_USER_INPUT` asking for a fuller context packet (timeline, decisions, constraints) before researcher/reviewer execution.
- Do not infer design intent from unstated/implicit chat history in this case.
- In this fail-safe branch, do not start researcher/reviewer execution until user input is received.

Team shape:
1) researcher
2) reviewer
3) researcher/reviewer loop until both approve each design part
4) orchestrator final review and coordination

Execution model:
- Use direct researcher <-> reviewer collaboration for fast iteration.
- Use orchestrator as a lightweight coordinator only (entrypoint, conflict resolution, final review of researcher-written artifacts).
- Keep every handoff explicit using ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.
- Researcher writes intermediate findings to `.opencode/design/.research/` during iteration, then writes the final design doc to `.opencode/design/`.
- Artifact creation must be done with filesystem tools (`Read`/`Write`/`Edit`), not shell commands.
- Do not run `ls`, `mkdir`, `date`, or similar shell commands just to prepare the artifact path.
- Use the session date context for `YYYYMMDD` in artifact filenames.

Permissions:
- Reviewer is read-only against the local workspace.
- Researcher can write intermediate findings to `.opencode/design/.research/` and final design artifacts to `.opencode/design/`.
- Orchestrator coordinates workflow and reads artifacts for final review but does not write them.
- If artifact creation fails because `.opencode/design/` or `.opencode/design/.research/` is missing or write access is blocked, researcher should return STATUS: blocked so orchestrator can emit `NEEDS_USER_INPUT` with:
  - exact path to create,
  - why write access is required,
  - what will be written (intermediate findings or final design markdown artifact).
- Researcher and reviewer may request network access, but network is denied by default.
- When external lookups are needed, emit STATUS: blocked with:
  - purpose,
  - requested domains,
  - timebox,
  - expected artifact.
- Orchestrator asks the user once and records decision in ARTIFACTS as:
  - NETWORK: approved_once | approved_phase | denied
- Without approval, continue offline and explicitly record uncertainty/risk.
- Do not create or update bd issues in this command.
- `/design` must never execute `bd create`, `bd dep add`, or any other bd mutation command.

Required output artifact:
- Produce one design doc artifact in `.opencode/design/` with:
  - Filename format: `YYYYMMDD-<slug>.md`
  - problem statement,
  - scope and non-goals,
  - chosen approach and rejected alternatives,
  - single epic + checklist breakdown,
  - explicit slice graph (DAG) with dependencies/order,
  - verification plan with executable checks and pass signals,
  - rollback strategy,
  - monitoring/observability plan,
  - `BD COMMANDS` section with copy/paste-ready commands to create corresponding bd issues later (default type `feature`, priority `P2`),
  - per-slice command coverage in `BD COMMANDS` that includes `bd create` inputs for title, type, priority, and description source, plus explicit `bd dep add` wiring for slice dependencies,
  - `BD COMMANDS` must be executable with only ID substitution (for example replacing `<epic-id>` and `<slice-id>` placeholders) and no additional command authoring,
  - one `PATCH READY` block per implementation slice using this format:

PATCH READY
Design source: <path-or-id>
Epic: <bd-epic-id-or-placeholder>
Slice ID: <unique-slice-id>
Task: <one-sentence implementable ask>
Scope: <allowed files/dirs>
Non-goals: <what not to change>
Commit intent: <commit|no-commit-needed>
Acceptance:
- <criteria>
Proof commands:
- Run: <command>
  Pass: <explicit pass signal>
Dependencies: <slice ids or none>
Rollback: <how to revert safely>
Monitoring: <logs/metrics/signals to watch>
Risk: <low|medium|high>

- Ensure these `PATCH READY` blocks are designed to be consumed directly by `/implement` in planned mode from either:
  - a design doc reference (for example `/implement start work on @design-doc.md`), or
  - a beads epic/task reference that mirrors this metadata.
- Target at least 5 slices for medium+ features, and allow 10+ slices when the problem naturally decomposes.
- Design slices to support multi-commit autonomous execution where dependencies permit non-serial readiness.
- Keep each slice sized for one atomic commit when `Commit intent` is `commit`.

Exit criteria:
- End at STATUS: ready_for_user.
- Do not mark `ready_for_user` unless the design artifact contains a complete `BD COMMANDS` section where every planned slice has executable `bd create` and `bd dep add` coverage requiring only ID substitution.
- Stop and return `NEEDS_USER_INPUT` so the parent can collect user approval/iteration feedback.
- Do not auto-start patch/build teams from this command.
