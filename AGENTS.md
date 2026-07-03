# Repository Guidelines

## Dotfiles Conventions

Instructions go in `AGENTS.md` (all agents read it). `CLAUDE.md` is for Claude-specific config only. Never duplicate the same rule in both files.

This repo uses an opt-in gitignore (`/*` ignores everything at root; specific paths are whitelisted). New files in ignored dirs require `git add -f`. If `git add` silently does nothing, check `.gitignore` for a blocking rule.

## Personal Knowledge Store

Two documented-solutions stores exist, both organized by category with YAML frontmatter (`module`, `tags`, `problem_type`):

- `docs/solutions/` — project-scoped learnings, relevant only to this repo.
- `~/.agents/docs/solutions/` — cross-project learnings, relevant when debugging or working in a documented area regardless of repo.

When running `/ce-compound`, default to writing docs to `docs/solutions/<category>/` as usual. Only write to `~/.agents/docs/solutions/<category>/` instead when the learning is explicitly cross-project (applies beyond this repo).

## Session Learning Capture

Watch for friction during any session:
- User corrected a pattern or preference (once or repeatedly)
- Non-obvious solution was found through investigation
- User stated a convention or preference they want going forward
- A script was written and used but not persisted
- A skill was invoked and its instructions were wrong or incomplete

When a session reaches a natural end and any friction was observed, offer to run `/post-session-learning` before the user leaves. One short sentence is enough: "Want me to capture what we learned so this is automatic next time?" Do not offer if the session had no friction worth capturing (pure Q&A, trivial tasks).


## Build, Test, and Development Commands
- Start a prepared shell with `devbox shell` from the repo root; add packages in `.config/devbox/devbox.json`.
- Run all pre-commit hooks with `pre-commit run --all-files`.
- Run shell linting via `shellcheck bin/` and Python quality checks with `pylint --rcfile .config/pylintrc`.
- Syntax-check fish configs with `fish -n .config/fish/conf.d/*.fish .config/fish/functions/*.fish`.

## Coding Style & Naming Conventions
- YAML follows two-space indentation, 120 character lines, and lower-case keys.
- Python adopts snake_case modules, f-string formatting, and max 120 char lines per `.config/pylintrc`.
- Shell scripts in `bin/` should target bash, include `set -euo pipefail`, and log actions with succinct `echo` statements.
- Fish configs in `.config/fish/conf.d/` use 4-space indentation and prefer `set -l` for local variables.

## Fish Shell Patterns

### conf.d files
- Use numeric prefixes to encode load dependencies (see README for the mapping).
- Every new conf.d file should follow the main/install pattern:
  ```fish
  function main       # runs on every interactive shell
      ...
  end

  function install    # runs on login shells (once per session)
      ...
  end

  status --is-login; and install
  status --is-interactive; and main
  ```
- This avoids paying install costs (package syncs, git fetches) on every new terminal tab.

### Shared utilities
- Use `is_expired` from `functions/is_expired.fish` for all TTL-based file regeneration; do not define local copies.
- Cross-platform stat for file modification times — `stat` flags differ between Linux and macOS:
  ```fish
  set -l file_age (stat -c %Y $file 2>/dev/null; or stat -f %m $file 2>/dev/null; or echo 0)
  ```

### pyenv
- `20-virtualenv.fish` inlines `pyenv init -` to avoid subshell overhead (~100 ms saved). Always use `(pyenv root)` at runtime; never hardcode user-specific paths like `/Users/name/.pyenv/`.

## Testing Guidelines
- Prefer targeted lint runs (`shellcheck bin/`, `pylint`) before pushing.
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
