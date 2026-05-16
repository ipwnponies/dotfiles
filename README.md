# dotfiles

Personal dotfiles for Fish shell, Neovim, and assorted CLI tools.

The repo lives directly at `$HOME`. The root `.gitignore` ignores everything (`/*`) and
whitelists only tracked paths, turning the home directory into a sparse git repo.

## Quick setup

Run from your home directory:

```sh
cd ~
git init
git remote add origin https://github.com/ipwnponies/dotfiles.git
git fetch origin
git switch --create main origin/main
```

## Structure

| Path | Purpose |
|------|---------|
| `bin/` | Host-agnostic CLI helpers (`git-deploy`, `git-clean-remote`, `pomodoro`, …) |
| `.config/fish/` | Fish shell configuration |
| `.config/nvim/` | Neovim configuration (Lua, lazy.nvim) |
| `.config/devbox/` | Devbox package manifest for dev tools |
| `.config/aqua/` | Aqua package manager manifest |
| `.config/npm/` | npm global package manifest |
| `.config/venv-update/` | Poetry project for Python CLI tools |

## Fish shell

`conf.d/` files load in alphanumeric order. Numeric prefixes control priority:

- `05-*` — XDG paths, SSH agent, base environment
- `10-*` — Devbox integration
- `15-*` — AI tooling (opencode)
- `20-*` — Language toolchains (cargo, go, npm, Python/pyenv)
- Unprefixed — Individual tool integrations (zoxide, fzf, direnv, …)
- `z-wait.fish` — Runs last; waits for background jobs started above

Each file follows a `main` / `install` pattern:
- `install` runs on **login** shells to sync packages in the background
- `main` runs on **interactive** shells to configure the environment

## Adding packages

| Ecosystem | File |
|-----------|------|
| CLI tools | `.config/devbox/devbox.json` — run `devbox global install` |
| Python tools | `.config/venv-update/pyproject.toml` — runs via `poetry sync` on login |
| Node tools | `.config/npm/package.json` — runs via `npm ci` on login |
| Aqua tools | `.config/aqua/aqua.yaml` |
