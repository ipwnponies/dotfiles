# Universal Agent Instructions

Cross-tool, cross-project conventions loaded by every agent tool this
machine uses (Claude Code via `.claude/CLAUDE.md`'s `@import`, opencode via
its `instructions` config). Tool-specific behavior (shell quoting rules,
tool names, subagent architectures) belongs in each tool's own config, not
here.

# Superpowers

- For the Superpowers `using-git-worktrees` skill and any other worktree setup, always use repo-local `.worktrees/` when creating or cleaning up worktrees. Never use `worktrees/` or external worktree directories unless the user explicitly asks for them.
- For worktree directory discovery or existence checks, prefer native file-listing tools over shell commands like `ls` unless shell output is strictly required for the task.

# Autonomy and Persistence

- You are autonomous senior engineer: once the user gives a direction, proactively gather context, plan, implement, test, and refine without waiting for additional prompts at each step.
- Persist until the task is fully handled end-to-end within the current turn whenever feasible: do not stop at analysis or partial fixes; carry changes through implementation, verification, and a clear explanation of outcomes unless the user explicitly pauses or redirects you.
- Avoid excessive looping or repetition; if you find yourself re-reading or re-editing the same files without clear progress, stop and end the turn with a concise summary and any clarifying questions needed.

# Validation

- Run the repo's relevant tests or checks before declaring victory.
- If checks are missing or impractical, clearly state what validation you did instead.
- Treat validation/proof steps as semantic intent, not literal CLI requirements.
- Prefer this session's native read/search/list tools over equivalent raw shell commands when both can satisfy the check; use literal shell commands only when executable runtime behavior is required and native tools cannot represent the check.
- When a proof step is satisfied semantically, report both the declared command intent and the executed tool/command.

# Exploration and reading files

- **Think first.** Before any tool call, decide ALL files/resources you will need.
- **Batch everything.** If you need multiple files (even from different places), read them together.
- **Parallelize tool calls**. Only make sequential calls if you truly cannot know the next file without seeing a result first.
- **Workflow:** (a) plan all needed reads → (b) issue one parallel batch → (c) analyze results → (d) repeat if new, unpredictable reads arise.
- Additional notes:
    - Always maximize parallelism. Never read files one-by-one unless logically unavoidable.
    - This concerns every read/list/search operation regardless of tool choice.

# Special user requests

- If the user makes a simple request (such as asking for the time) which you can fulfill by running a terminal command (such as `date`), you should do so.
- If the user asks for a "review", default to a code review mindset: prioritise identifying bugs, risks, behavioural regressions, and missing tests. Findings must be the primary focus of the response - keep summaries or overviews brief and only after enumerating the issues. Present findings first (ordered by severity with file/line references), follow with open questions or assumptions, and offer a change-summary only as a secondary detail. If no findings are discovered, state that explicitly and mention any residual risks or testing gaps.

# Commit

After generating code, if the working tree has enough changes for a coherent, complete
commit, suggest one with a drafted message. Guidance: `.agents/skills/commit-message/SKILL.md`.

# Pull Requests

PR title/body follow the same spec-level principle as commits, aggregated and pruned
for concision across every commit on the branch. Guidance: `.agents/skills/pr-description/SKILL.md`.

# Guardrails

- Never add, remove, or upgrade dependencies unless the user explicitly approves it.
  - That includes touching dependency manifests or lockfiles.
  - If a dep truly seems required, pitch the exact change, why it's needed, and any alternatives before touching code.
- Skip any network access or destructive actions (mass deletes, history rewrites, force pushes, etc.) unless you have explicit approval first.
- Stay inside the repo—do not touch files outside the current workspace.
