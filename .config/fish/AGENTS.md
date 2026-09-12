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
- `05-env.fish` — XDG dirs and PATH; must load first so later files can use `$XDG_*`
- `05-ssh_agent.fish` — starts/loads the ssh-agent via `keychain`; no ordering
  dependency on `05-env.fish`, just grouped with it as core environment setup
- `10-devbox.fish` — devbox integration; uses `$XDG_DATA_HOME`, `$XDG_STATE_HOME`,
  and `$XDG_CONFIG_HOME` from `05-env.fish`, so must load after it
- `15-opencode.fish` — sets `OPENCODE_MODEL_*` env vars for AI tooling; no
  cross-file dependency
- `20-cargo.fish`, `20-go.fish`, `20-npm.fish`, `20-virtualenv.fish` — language
  ecosystem package managers; each sets install paths and adds bins to PATH using
  `$XDG_*` vars from `05-env.fish`

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

`status --is-interactive` runs only in interactive shells; `status --is-login`
runs only in login shells (the first shell on login).

Use the **interactive guard** for user-facing quality-of-life config:
abbreviations, prompt customization, keybindings, UI-only tool setup. These
make no sense in scripts or non-interactive subprocesses.

Use the **login guard** for infrequent, heavier operations — package installs,
syncing tools, updating generated files — where eventual consistency is
acceptable.

For a file that only needs one guard, either inline it:

```fish
if status --is-interactive
    ...
end
```

(see `man.fish`, `zoxide.fish`), or guard a function call (see `direnv.fish`,
`fuck.fish`):

```fish
function main
    ...
end

status --is-interactive; and main
```

A file that needs both — light interactive setup plus heavier login-time
install/sync work — combines both guards via the main/install split (see
`10-devbox.fish`, `20-npm.fish`, `20-virtualenv.fish`, `omf.fish`):

```fish
function main       # runs on every interactive shell
    ...
end

function install    # runs on login shells
    ...
end

status --is-login; and install
status --is-interactive; and main
```

`main` and `install` are plain global functions, not scoped to the file that
defines them — once all conf.d files finish sourcing, whichever file defined
them last (alphabetically) wins for the rest of the session. That's fine for
the guarded calls above, since each fires immediately, before the next file
can redefine it — but never call `main`/`install` manually later expecting a
specific file's logic. It also means `install` can run again in another login
shell before the first finishes, so make it idempotent (see the
`test -d`/`is_expired` guards in `20-virtualenv.fish` and `omf.fish`).

This avoids paying install costs (package syncs, git fetches) on every new terminal tab.

### Backgrounding expensive installs

If `install` shells out to something that can be slow or network-dependent
(package manager sync, registry check), background it so login doesn't block
on it:

```fish
status --is-login; and install &
```

`cargo.fish`, the poetry sync in `20-virtualenv.fish`, `10-devbox.fish`, and
`20-go.fish` all do this. Combine with an `is_expired` stamp-file guard (below)
so the expensive call is also skipped outright most logins, not just moved
off the critical path — otherwise every login still pays the full cost, just
in parallel instead of in sequence.

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

## Style

- 4-space indentation.
- Prefer `set -l` for local variables.

## Shared utilities

- Use `is_expired` from `functions/is_expired.fish` for all TTL-based file regeneration; do not define local copies.
  - Signature: `is_expired $stamp_file [$watch_file ...]`. Expired if the stamp
    is missing, older than one week, or older than any watch file (`-nt`
    check). Watch files only ever shorten the wait (force-expire on a source
    change, e.g. `devbox.json`/`devbox.lock`) — they never extend it past the
    week TTL.
  - After the guarded work succeeds, `touch` the stamp file — do this last,
    after the install call, so a failed/partial run doesn't get marked fresh.
    See `install` in `10-devbox.fish` and `install_aqua_tools` in `20-go.fish`.
- Cross-platform stat for file modification times — `stat` flags differ between Linux and macOS:
  ```fish
  set -l file_age (stat -c %Y $file 2>/dev/null; or stat -f %m $file 2>/dev/null; or echo 0)
  ```

## pyenv

`20-virtualenv.fish` inlines `pyenv init -` to avoid subshell overhead (~100 ms saved). Always use `(pyenv root)` at runtime; never hardcode user-specific paths like `/Users/name/.pyenv/`.

## Adding a new tool integration

1. Create `conf.d/<priority>-<toolname>.fish` with the right numeric prefix.
2. Set env vars with `set -x`, add bins with `fish_add_path`.
3. If it needs login-time install/sync work, follow the main/install pattern
   above; otherwise use a single guard. If the install/sync call is slow or
   network-dependent, background it and gate it with an `is_expired`
   stamp file (see Backgrounding expensive installs and Shared utilities
   above).
4. If the tool generates completions dynamically, cache them with `is_expired` (see Shared utilities above).
5. If completions are static, add a file to `completions/<toolname>.fish`.
