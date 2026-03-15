---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

MESSAGE_MODE: interactive

Input: `$ARGUMENTS`

Commit message handling:
- Use the classifier and precedence from `.config/opencode/agents/committer.md`: `complete_message` > `clear_intent` > `ambiguous_question`.
- In `MESSAGE_MODE: interactive`, if a final complete message is not already available, return a draft via parent-mediated iteration and commit only after explicit final message/approval per policy.
- If classification is ambiguous or user intent/approval state is unclear, return `NEEDS_USER_INPUT` and stop.
- For `NEEDS_USER_INPUT`, follow the structured YAML contract from `.config/opencode/agents/committer.md` (including `kind`, `on_reply`, `recommended`, and `default` semantics) and do not apply conflicting fallback/default behavior in this command file.
- Empty input should be handled by the classifier/policy path (no extra command-local override rules).

Execution semantics and git safety rules are defined in the committer agent policy at `.config/opencode/agents/committer.md`.
