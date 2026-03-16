---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

Input: `$ARGUMENTS`

Mode selection for `/commit`:
- If `$ARGUMENTS` is empty, run in `MESSAGE_MODE: auto` and let the committer complete the commit end-to-end.
- If `$ARGUMENTS` is provided, first classify it using `.config/opencode/agents/committer.md` precedence: `complete_message` > `clear_intent` > `ambiguous_question`.
- If classified as `complete_message`, validate it against the committer message policy (Conventional Commit subject format, required type prefix, subject length, and any other active constraints).
- If `complete_message` is valid, run in `MESSAGE_MODE: auto` and use that message as final.
- If `complete_message` is invalid, switch to `MESSAGE_MODE: interactive` and request correction via parent-mediated `NEEDS_USER_INPUT`.
- If input is not a commit message (`clear_intent` or `ambiguous_question`), run in `MESSAGE_MODE: interactive`.

Parent context contract (only needed when commit intent/message is inferred from conversation):
- If `$ARGUMENTS` contains a valid complete commit message, parent context is optional.
- If commit intent/message is inferred from conversation (for example interactive refinement after ambiguous/non-message input), parent should include relevant recent context in the task prompt and continue passing user replies on resumed `task_id` turns.
- Because this command runs with `subtask: true`, do not assume direct access to the full parent chat transcript unless the parent explicitly provides it.
- If parent-supplied context is missing and intent/approval is unclear, return `NEEDS_USER_INPUT` instead of guessing.

Interactive behavior rules:
- In `MESSAGE_MODE: interactive`, if a final complete message is not available, return a draft via parent-mediated iteration and commit only after explicit final message/approval per policy.
- If classification is ambiguous or intent/approval state is unclear, return `NEEDS_USER_INPUT` and stop.
- For `NEEDS_USER_INPUT`, follow the structured YAML contract from `.config/opencode/agents/committer.md` (including `kind`, `on_reply`, `recommended`, and `default` semantics) and do not apply conflicting fallback/default behavior in this command file.

Execution semantics and git safety rules are defined in the committer agent policy at `.config/opencode/agents/committer.md`.
