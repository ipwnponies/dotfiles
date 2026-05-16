# Repository Guidelines

## Personal Knowledge Store

`~/.agents/docs/solutions/` — documented solutions to past problems (bugs, best practices, workflow patterns), organized by category with YAML frontmatter (`module`, `tags`, `problem_type`). Relevant when debugging or working in a documented area.

When running `/ce-compound`, write docs to `~/.agents/docs/solutions/<category>/` instead of the default `docs/solutions/`.

## Session Learning Capture

Watch for friction during any session:
- User corrected a pattern or preference (once or repeatedly)
- Non-obvious solution was found through investigation
- User stated a convention or preference they want going forward
- A script was written and used but not persisted
- A skill was invoked and its instructions were wrong or incomplete

When a session reaches a natural end and any friction was observed, offer to run `/post-session-learning` before the user leaves. One short sentence is enough: "Want me to capture what we learned so this is automatic next time?" Do not offer if the session had no friction worth capturing (pure Q&A, trivial tasks).

## Project Structure & Module Organization
- `bin/` contains host-agnostic CLI helpers (e.g., `bin/git-clean-remote`, `bin/pomodoro`); keep each file executable and documented with a header comment.
- `.config/` mirrors application settings for fish, neovim, taskwarrior, etc.; keep app-specific docs inside the directory README when necessary and prefer per-app subfolders.
- `tools/` holds the Devbox definition used to provision auxiliary utilities (`tools/devbox.json`), and `repos/` tracks checked-out upstream projects that should remain untouched unless syncing from their sources.

## Build, Test, and Development Commands
- Start a prepared shell with `devbox shell` from the repo root; add packages in `tools/devbox.json`.
- Validate YAML changes with `yamllint -c .config/yamllint/config config automations.yaml scenes.yaml`.
- Run shell linting via `shellcheck bin/git-clean-remote` and Python quality checks with `pylint --rcfile .config/pylintrc volta.py`.

## Coding Style & Naming Conventions
- YAML follows two-space indentation, 120 character lines, and lower-case keys; structure automations by domain (e.g., `automation.lights_evening`).
- Python adopts snake_case modules, f-string formatting, and max 120 char lines per `.config/pylintrc`; add lightweight typer commands to `volta.py`.
- Shell scripts in `bin/` should target POSIX sh, guard against `set -eu`, and log actions with succinct `echo` statements.

## Testing Guidelines
- Group new YAML automations under matching blueprint directories and include comments noting dependencies.
- Prefer targeted lint runs (`yamllint config/blueprints`, `pylint volta.py`) before pushing.
- When modifying third-party mirrors in `repos/`, open patches upstream first—local diffs should be temporary and documented in the PR.

## Commit & Pull Request Guidelines
- Use Conventional Commit subjects: `type: short description` or `type(scope): short description`.
- Keep commit subjects under 70 characters and use a precise type (`feat`, `fix`, `docs`, `refactor`, `chore`) that matches the change intent.
- Use scope when helpful in this multi-project repo (for example `fix(venv): ...`, `chore(agent): ...`), and derive scope names from existing git history to stay consistent.
- If multiple scopes seem possible, pick the one already used most often in recent commits for the same area.
- For non-trivial changes, add a short body (1-2 sentences) that explains why the change exists and the expected impact; avoid file-by-file narration.
- Reference related issues or upstream PRs in the body, and attach screenshots or logs when UI or automation behavior changes.
- PR descriptions should restate expected behavior, test evidence (commands above), and any rollout or secret-handling notes; request review from domain owners when touching their area.

<!-- BEGIN BEADS INTEGRATION -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Dolt-powered version control with native sync
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update <id> --claim --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task atomically**: `bd update <id> --claim`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs via Dolt:

- Each write auto-commits to Dolt history
- Use `bd dolt push`/`bd dolt pull` for remote sync
- No manual export/import needed!

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

<!-- END BEADS INTEGRATION -->
