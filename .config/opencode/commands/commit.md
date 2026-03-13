---
description: Run the committer workflow
agent: committer
subtask: true
---
Do your standard committer workflow for the current repository.

Input: `$ARGUMENTS`

Commit message handling:
- If input is empty, use your normal message drafting process from the staged/unstaged changes.
- If input entirely looks like a complete commit message (subject-only or full multi-line message), use it as-is with no rewrites.
- If it is ambiguous whether input is a commit message or intent/context, return `NEEDS_USER_INPUT` so the parent can ask the user whether the input was meant to be the commit message.
- Otherwise, treat the input as intent/context and use it to inform a commit message that still reflects the actual code changes.

When deciding if input is a complete commit message, prefer "use as-is" if it reads like a finished message rather than an instruction.

Execution semantics and git safety rules are defined in the committer agent policy at `.config/opencode/agents/committer.md`.
