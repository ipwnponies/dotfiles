---
description: Design research flow (researcher <-> reviewer, orchestrator finalizes, user approval gate)
agent: orchestrator
subtask: false
---
Run the Design workflow for this request: `$ARGUMENTS`.

This command is design-only. Do not implement code changes.

Team shape:
1) researcher
2) reviewer
3) researcher/reviewer loop until both approve each design part
4) orchestrator final packaging

Execution model:
- Use direct researcher <-> reviewer collaboration for fast iteration.
- Use orchestrator as a lightweight finalizer only (entrypoint, conflict resolution, final artifact packaging).
- Keep every handoff explicit using ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS.

Permissions:
- Researcher and reviewer are read-only against the local workspace.
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

Required output artifact:
- Produce one design doc artifact with:
  - problem statement,
  - scope and non-goals,
  - chosen approach and rejected alternatives,
  - single epic + checklist breakdown,
  - dependencies/order,
  - verification plan with executable checks and pass signals,
  - rollback strategy,
  - monitoring/observability plan,
  - bd-ready section with near-copy/paste instructions to create corresponding bd issues later (default type `feature`, priority `P2`),
  - one `PATCH READY` block per implementation slice using this format:

PATCH READY
Design source: <path-or-id>
Epic: <bd-epic-id-or-placeholder>
Slice ID: <unique-slice-id>
Task: <one-sentence implementable ask>
Scope: <allowed files/dirs>
Non-goals: <what not to change>
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

Exit criteria:
- End at STATUS: ready_for_user.
- Stop and wait for user approval/iteration.
- Do not auto-start patch/build teams from this command.
