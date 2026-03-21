---
name: design
description: Design workflow skill with inferred-intent context handoff.
---

# Design Orchestration

## Purpose

- Provide a consistent skill-first entrypoint for design-only workflow execution.
- Route work through orchestrator subtask execution of `.config/opencode/commands/design.md`.

## Trigger examples

- Use this skill when the user asks to design, plan, or scope work before coding.
- Positive examples:
  - "Design a solution for adding offline sync to notes."
  - "Create a rollout plan for migrating auth providers."
  - "I want a design doc before implementation."
  - "Break this feature into implementation slices with acceptance criteria."
- Prefer other skills/flows when the user asks to directly code changes now without a design artifact.

## Intake rules

- If the user provides explicit design intent, use it as `$ARGUMENTS`.
- If no intent is provided, infer candidates from recent conversation context only.

## Context packet contract

- Do not pass one-line context summaries when prior discussion exists.
- If prior discussion exists (including a single long turn), include a structured context packet in orchestrator task input.
- Use this exact envelope when dispatching to `/design` (for both explicit and inferred intent):
  - `Recent conversation context:`
  - `Current user intent:`
  - `Decisions made:`
  - `Constraints and approvals:`
  - `Git/worktree context:`
  - `Open questions and risks:`
  - `Referenced artifacts:`
- Coverage guidance:
  - Capture enough detail to preserve user intent, decisions, and constraints without forcing fixed minimums or maximums.
  - `Recent conversation context:` preserve material context in the level of detail needed for accurate execution.
  - `Decisions made:` include accepted/rejected decisions when design choices were discussed.
  - `Constraints and approvals:` include explicit safety/tool/network approvals or denials when mentioned.
  - `Git/worktree context:` is optional parent-owned context; if omitted, do not ask orchestrator or child roles to inspect git state or the working tree just to recover it.
- In inferred-intent mode, include an additional section:
  - `Inferred design intent:`

## Deterministic subtask dispatch

- Dispatch to `orchestrator` as a subtask target for `/design`.
- Treat `/design` as mandatory, not advisory: this skill must not execute researcher/reviewer work inline in the current agent.
- Always use the agent-team path because researcher/reviewer permissions and artifact-writing boundaries live there.
- Always pass either explicit `$ARGUMENTS` or an inferred-intent prompt, and include the context packet envelope whenever prior discussion exists.
- For `NEEDS_USER_INPUT`, ask exactly one question and resume the same task session via `task_id` with the user response and updated constraints.
- Git/worktree state is parent-owned context. The parent may provide it explicitly in `Git/worktree context:`; if it is not provided, do not instruct `orchestrator` or downstream roles to inspect git state or the working tree to fill the gap.
- Do not generate instructions such as "inspect the current working tree first" or "determine whether to keep/fix/replace parent edits." Either include that context up front or proceed without it.
- If `/design` dispatch cannot run, stop and surface the blocker instead of bypassing the team workflow locally.

## Empty-input fail-safe

- If `$ARGUMENTS` is empty and the required envelope is missing or substantially empty, do not run the design loop.
- Return `NEEDS_USER_INPUT` requesting one of:
  - one-line explicit design intent, or
  - confirmation to proceed with artifact-only discovery.

## Residual dependency

- This skill assumes runtime support for command-to-subtask dispatch and task resume (`task_id`).
- If dispatcher support is unavailable, construct and return the exact envelope text for the user/parent to pass into `/design` manually, then stop.
- Do not fall back to direct design execution in the current agent as a substitute for the team workflow.
