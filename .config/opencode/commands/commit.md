---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

## Conversation-scoped manifest
- If the parent commit skill supplies a `STAGE_MANIFEST`, treat it as the scope contract: stage exactly `STAGE_MANIFEST.include`; do not add or infer additional files; leave every path in `STAGE_MANIFEST.exclude` untouched so the parent/patch skill can keep the dirty worktree intact.
- If `STAGE_MANIFEST` is missing, fall back to the delegated committer agent policy. In particular, when `git diff --staged` is non-empty, treat the staged index as the deliberate commit scope and proceed without asking for a manifest.
- Only return `NEEDS_USER_INPUT` (`kind: scope_change`) for missing manifest when the committer agent policy would otherwise require clarification, such as when nothing is staged and the intended scope is still ambiguous.

MESSAGE_MODE: auto

Input: `$ARGUMENTS`

Commit message handling is fully defined by the delegated committer agent policy.
- Use classifier precedence exactly as defined there.
- If classifier returns `FINAL_MESSAGE` from `$ARGUMENTS`, treat it as final and proceed unless a safety/correctness guardrail requires confirmation.
- If classifier returns `INTENT_CONTEXT` from `$ARGUMENTS`, treat input as guidance and draft/refine a message that matches the staged/unstaged changes.
- Use the structured `NEEDS_USER_INPUT` YAML contract defined there.
- Do not add command-local fallback/default behavior that conflicts with agent policy.

Execution semantics and git safety rules are defined by the delegated committer agent policy.
