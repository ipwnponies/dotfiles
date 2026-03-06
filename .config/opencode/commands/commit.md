---
description: Stage selected files and create one commit (with approval gate)
agent: committer
subtask: false
---
Prepare a single local commit for the current working tree.

- Use only allowed git commands.
- Inspect current state first (`status`, unstaged/staged diff, recent log).
- Stage only files related to this task, and call out excluded files.
- Do not stage possible secret files unless I explicitly approve.
- Draft a high-quality commit message using:
  - one subject line in `type: summary` format
  - blank line
  - 2-5 bullets describing intent, behavior changes, and notable risks
- Print the full proposed commit message in normal assistant output before the first `question` prompt.
- Keep `question` prompts short and simple during message iteration:
  - first prompt options: `Use draft`, `Refine draft`, `Provide custom message`
  - if refining, ask one short focused follow-up (tone, scope, or risk detail) and redraft
  - repeat until the user approves the draft or provides a final full message
- Show: (1) files to stage, (2) files excluded, (3) proposed message.
- STOP and wait for my explicit approval before running `git add`/`git commit`.
- If I provide a revised message, use it exactly.
- After committing, report a concise human summary (commit hash, subject, short file/change stats) without echoing shell commands.
