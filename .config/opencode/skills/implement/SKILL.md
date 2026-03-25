---
name: implement
description: Implement workflow skill with inferred-intent context handoff.
---

# Implement Orchestration

## Purpose

- Provide a consistent skill-first entrypoint for autonomous implementation workflow execution.
- Route work through orchestrator subtask execution of `.config/opencode/commands/implement.md`.

## Trigger examples

- Use this skill when the user asks to implement, build, or execute approved work across one or more related slices.
- Positive examples:
  - "Implement this change now."
  - "Go build the slices from @design-20260316-auth-migration.md."
  - "Start implementation from this beads task and ship commits."
- Use the `patch` skill instead when the user wants one scoped slice with a stop for review before any commit handoff.
- Prefer design/planning skills when the user asks for analysis-first output without code changes.

## Intake rules

- If the user provides explicit implementation intent, use it as `$ARGUMENTS`.
- If no intent is provided, infer candidates from recent conversation context only.

## Context packet contract

- Do not pass one-line context summaries when prior discussion exists.
- If prior discussion exists (including a single long turn), include a structured context packet in orchestrator task input.
- Use this exact envelope when dispatching to `/implement` (for both explicit and inferred intent):
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
  - `Decisions made:` include accepted/rejected decisions when implementation choices were discussed.
  - `Constraints and approvals:` include explicit safety/tool/network approvals or denials when mentioned.
  - `Git/worktree context:` is optional parent-owned context; if omitted, do not ask orchestrator or child roles to inspect git state or the working tree just to recover it.
- In inferred-intent mode, include an additional section:
  - `Inferred build intent:`

## Deterministic subtask dispatch

- Dispatch to `orchestrator` as a subtask target for `/implement`.
- Treat `/implement` as mandatory, not advisory: this skill must not execute implementer/reviewer/fixer/qa/committer work inline in the current agent.
- Always use the agent-team path because the specialized roles own the needed prompts, permissions, and commit/QA boundaries.
- Always pass either explicit `$ARGUMENTS` or an inferred-intent prompt, and include the context packet envelope whenever prior discussion exists.
- For `NEEDS_USER_INPUT`, ask exactly one question and resume the same task session via `task_id` with the user response and updated constraints.
- Git/worktree state is parent-owned context. The parent may provide it explicitly in `Git/worktree context:`; if it is not provided, do not instruct `orchestrator` or downstream roles to inspect git state or the working tree to fill the gap.
- Do not generate instructions such as "inspect the current working tree first" or "determine whether to keep/fix/replace parent edits." Either include that context up front or proceed without it.
- If `/implement` dispatch cannot run, stop and surface the blocker instead of bypassing the team workflow locally.

## Workflow defaults

- Treat `implement` as the autonomous path: once started, continue through the related in-scope workset until blocked, out of ready slices, or out of budget.
- Process ready slices sequentially, not as one large batch; each completed logical slice should produce its own review, QA, and commit outcome.
- Fulfill clearly related follow-on work that belongs to the same approved request or plan, but do not opportunistically pull in unrelated backlog items.
- Commit per completed logical slice rather than waiting until the entire workset is done.

## Empty-input fail-safe

- If `$ARGUMENTS` is empty and the required envelope is missing or substantially empty, do not infer implementation intent.
- Return `NEEDS_USER_INPUT` requesting one of:
  - one-line explicit build/implementation intent, or
  - confirmation to proceed with artifact-only discovery.

## Residual dependency

- This skill assumes runtime support for command-to-subtask dispatch and task resume (`task_id`).
- If dispatcher support is unavailable, construct and return the exact envelope text for the user/parent to pass into `/implement` manually, then stop.
- Do not fall back to direct implementation execution in the current agent as a substitute for the team workflow.
