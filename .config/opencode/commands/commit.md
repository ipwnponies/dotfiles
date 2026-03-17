---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

MESSAGE_MODE: interactive
INTERACTIVE_MAX_ROUNDS: 2

Input: `$ARGUMENTS`

Commit message handling is fully defined in `.config/opencode/agents/committer.md`.
- Use classifier precedence exactly as defined there.
- If classifier returns `FINAL_MESSAGE` from `$ARGUMENTS`, treat it as final and proceed without interactive iteration (auto-like path).
- If classifier returns `INTENT_CONTEXT` from `$ARGUMENTS`, treat input as guidance and draft/refine a message that matches the staged/unstaged changes.
- Use the structured `NEEDS_USER_INPUT` YAML contract defined there.
- Do not add command-local fallback/default behavior that conflicts with agent policy.

Execution semantics and git safety rules are defined in the committer agent policy at `.config/opencode/agents/committer.md`.
