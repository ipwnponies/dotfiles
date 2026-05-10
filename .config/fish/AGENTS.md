# Fish Shell Config

## Directory layout

| Path | Purpose |
|---|---|
| `conf.d/` | Sourced at shell startup in filename order |
| `functions/` | Autoloaded on first call — no startup cost |
| `completions/` | Tab-completion definitions, autoloaded |
| `plugins/` | OMF plugin hooks |

## conf.d load order

Files are sourced alphabetically. The numeric prefix controls ordering:

| Prefix range | Role |
|---|---|
| `00-` | Generated files — never edit manually (e.g. `00-devbox-generated_local.fish`) |
| `05-` | Core env: XDG dirs, PATH bootstrap — must load before anything uses `$XDG_*` |
| `10-` | Dev environment managers (devbox) |
| `15-` | AI/coding tools (opencode, codex) |
| `20-` | Language toolchain paths (cargo, go, npm, virtualenv) |
| no prefix | Tool integrations with no ordering dependency (abbr, direnv, fzf, etc.) |

New tool integrations that only set env vars or PATH go at `20-`. If a new
file must read variables set by another conf.d file, choose a higher number.

## Fish variable and env var conventions

```fish
set -x VAR value          # export env var (not: export VAR=value)
set -gx VAR value         # global + exported (equivalent for top-level conf.d)
fish_add_path DIR         # append to PATH deduplicating (not: PATH="$DIR:$PATH")
fish_add_path --prepend DIR  # prepend (for higher-priority overrides)

set -g VAR value          # global fish variable (not exported)
set -l VAR value          # local to current scope/function
```

Do **not** use bash-style `export VAR=value` or `PATH=...` — these are
silently ignored or cause subtle issues in fish.

## Interactive vs login guards

```fish
status --is-interactive; and <expr>   # run only in interactive shells
status --is-login; and <expr>         # run only in login shells (first shell on login)
if status --is-interactive
    ...
end
```

Use the interactive guard for prompts, keybindings, and anything that would
produce output. Use the login guard for one-time setup (package installs,
submodule syncs).

## Abbreviations vs functions vs aliases

- **Abbreviations** (`abbr --global --add`): expand in the command line before
  execution; preferred for short command rewrites. Defined in `conf.d/abbr.fish`.
  Local overrides go in `conf.d/abbr_local.fish` (gitignored).
- **Functions** (`functions/`): full fish functions, autoloaded. Use for
  anything with logic, arguments, or multiple steps.
- **Aliases**: avoid — they are implemented as functions in fish anyway; use
  `abbr` or real functions instead.

## Local overrides pattern

Several conf.d files source a `*_local.fish` sibling when present:

```fish
set -l local_file (dirname (status --current-filename))/abbr_local.fish
if test -e $local_file
    source $local_file
end
```

Use this pattern when adding new conf.d files that need machine-specific
values. The `*_local.fish` files are gitignored.

## Adding a new tool integration

1. Create `conf.d/<priority>-<toolname>.fish` with the right numeric prefix.
2. Set env vars with `set -x`, add bins with `fish_add_path`.
3. Wrap install/sync logic in a function and call it guarded by `status --is-login`.
4. If the tool generates completions dynamically, cache them with a TTL check
   (see `10-devbox.fish` for the expiry pattern).
5. If completions are static, add a file to `completions/<toolname>.fish`.
