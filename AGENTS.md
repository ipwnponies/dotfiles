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
- Fish config style and patterns: see `.config/fish/AGENTS.md`.

## Testing Guidelines
- Prefer targeted lint runs (`shellcheck bin/`, `pylint`) before pushing.
- When modifying third-party mirrors in `repos/`, open patches upstream first—local diffs should be temporary and documented in the PR.

## Commit & Pull Request Guidelines
See `~/.agents/AGENTS.md`'s Commit and Pull Requests sections (and the
`commit-message`/`pr-description` skills they point to) for the base
Conventional Commits format, subject-length limit, and body conventions —
this section only adds dotfiles-specific extras.
- Use scope when helpful in this multi-project repo (for example `fix(venv): ...`, `chore(agent): ...`), and derive scope names from existing git history to stay consistent.
- If multiple scopes seem possible, pick the one already used most often in recent commits for the same area.
- Reference related issues or upstream PRs in the body, and attach screenshots or logs when UI or automation behavior changes.
- PR descriptions should restate expected behavior, test evidence (commands above), and any rollout or secret-handling notes; request review from domain owners when touching their area.
