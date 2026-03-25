---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

## Conversation-scoped manifest
- The parent commit skill must supply a `STAGE_MANIFEST` that lists only the files discussed/edited in this conversation (`include`) and every other dirty file (`exclude`).
- Stage exactly `STAGE_MANIFEST.include`; do not add or infer additional files. Leave every path in `STAGE_MANIFEST.exclude` untouched so the parent/patch skill can keep the dirty worktree intact.
- If the manifest is missing or inconsistent with the requested scope, return `NEEDS_USER_INPUT` (`kind: scope_change`) so the parent can rebuild the manifest from the conversation context before committing.

MESSAGE_MODE: auto

Input: `$ARGUMENTS`

Commit message handling is fully defined in `.config/opencode/agents/committer.md`.
- Use classifier precedence exactly as defined there.
- If classifier returns `FINAL_MESSAGE` from `$ARGUMENTS`, treat it as final and proceed unless a safety/correctness guardrail requires confirmation.
- If classifier returns `INTENT_CONTEXT` from `$ARGUMENTS`, treat input as guidance and draft/refine a message that matches the staged/unstaged changes.
- Use the structured `NEEDS_USER_INPUT` YAML contract defined there.
- Do not add command-local fallback/default behavior that conflicts with agent policy.

Execution semantics and git safety rules are defined in the committer agent policy at `.config/opencode/agents/committer.md`.
