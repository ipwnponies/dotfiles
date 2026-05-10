# Fish Shell Config

## Directory layout

| Path | Purpose |
|---|---|
| `conf.d/` | Sourced at shell startup in filename order |
| `functions/` | Autoloaded on first call — no startup cost |
| `completions/` | Tab-completion definitions, autoloaded |
| `plugins/` | OMF plugin hooks |

## conf.d load order

Files are sourced alphabetically. The numeric prefix exists solely to control
load order when one file depends on variables set by another. The numbers
themselves carry no meaning beyond their relative order — pick a number that
places the file after its dependencies and before anything that depends on it.
Files with no ordering dependency carry no prefix.

Current numeric files and their actual dependencies:
- `00-devbox-generated_local.fish` — generated, do not edit
- `05-env.fish` — XDG dirs and PATH; must be first so later files can use `$XDG_*`
- `05-ssh_agent.fish` — no deps on other conf.d files, `05` is just convention
- `10-devbox.fish` — reads `$XDG_CONFIG_HOME` from `05-env.fish`
- `15-opencode.fish` — no deps, number places it after devbox setup
- `20-cargo.fish`, `20-go.fish`, `20-npm.fish`, `20-virtualenv.fish` — read `$XDG_*` vars

## Fish variable and env var conventions

```fish
set -x VAR value          # export env var; at top level, scope is implicitly global
set -gx VAR value         # explicitly global + exported; same effect at top level
fish_add_path DIR         # append to PATH, deduplicating
fish_add_path --prepend DIR  # prepend (for higher-priority overrides)

set -g VAR value          # global fish variable, not exported
set -l VAR value          # local to current scope/function
```

`-g` is redundant at the top level of a conf.d file (top-level variables are
global by default) but makes intent explicit inside functions where `-l` is the
default.

## Interactive vs login guards

```fish
status --is-interactive; and <expr>   # run only in interactive shells
status --is-login; and <expr>         # run only in login shells (first shell on login)
if status --is-interactive
    ...
end
```

Use the **interactive guard** for user-facing quality-of-life config:
abbreviations, prompt customization, keybindings, UI-only tool setup. These
make no sense in scripts or non-interactive subprocesses.

Use the **login guard** for infrequent, heavier operations — package installs,
syncing tools, updating generated files — where eventual consistency is
acceptable. Combine both guards (`--is-interactive` and `--is-login`) so that
remote commands and programmatic subprocesses don't accidentally pay the cost
of these operations.

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
3. Wrap install/sync logic in a function and call it guarded by both
   `status --is-interactive` and `status --is-login`.
4. If the tool generates completions dynamically, cache them with a TTL check
   (see `10-devbox.fish` for the expiry pattern).
5. If completions are static, add a file to `completions/<toolname>.fish`.
