# Repository Guidelines

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
- Follow the existing `[scope] Short description` commit style, using scopes like `[nvim]`, `[fish]`, or `[devbox]`.
- Reference related issues or upstream PRs in the body, and attach screenshots or logs when UI or automation behavior changes.
- PR descriptions should restate expected behavior, test evidence (commands above), and any rollout or secret-handling notes; request review from domain owners when touching their area.
