---
name: implement
description: Implement workflow skill with inferred-intent context handoff.
---

# Implement Orchestration

## Purpose

- Provide a consistent skill-first entrypoint for build/implementation workflow execution.
- Route work through orchestrator subtask execution of `.config/opencode/commands/implement.md`.

## Trigger examples

- Use this skill when the user asks to implement, build, patch, or execute approved work.
- Positive examples:
  - "Implement this change now."
  - "Go build the slices from @design-20260316-auth-migration.md."
  - "Apply the planned patch and run the validation loop."
  - "Start implementation from this beads task and ship commits."
- Prefer design/planning skills when the user asks for analysis-first output without code changes.

## Intake rules

- If the user provides explicit implementation intent, use it as `$ARGUMENTS`.
- If no intent is provided, infer candidates from recent conversation context only.
- If inferred mode is used, include this exact prompt envelope in orchestrator task input:
  - `Recent conversation context:`
  - `Inferred build intent:`
  - `Constraints and approvals:`

## Deterministic subtask dispatch

- Dispatch to `orchestrator` as a subtask target for `/implement`.
- Always pass either:
  - explicit `$ARGUMENTS`, or
  - an empty-arguments prompt that contains the required envelope.
- For `NEEDS_USER_INPUT`, ask exactly one question and resume the same task session via `task_id` with the user response and updated constraints.

## Empty-input fail-safe

- If `$ARGUMENTS` is empty and the required envelope is missing or substantially empty, do not infer implementation intent.
- Return `NEEDS_USER_INPUT` requesting one of:
  - one-line explicit build/implementation intent, or
  - confirmation to proceed with artifact-only discovery.

## Residual dependency

- This skill assumes runtime support for command-to-subtask dispatch and task resume (`task_id`).
- If dispatcher support is unavailable, use the best equivalent: construct and return the exact envelope text for the user/parent to pass into `/implement` manually, then stop.
