# Fish Config Audit

Standing backlog for the `.config/fish/` audit. Findings are stable, addressed
over multiple sessions, and tracked here rather than in chat history.

Audit performed by static reading only — no `fish` binary was available in the
audit environment, so nothing was executed. Findings tagged `needs-verify` are
ones where runtime behaviour decides whether the finding is real.

## How to use this doc

- **IDs are permanent.** `S1`, `C7`, `P3`, `H2`, `PRJ-4` never get renumbered or
  reused, even after a finding is closed or rejected. Reference them in commit
  messages (`fix(fish): correct Darwin detection (C1)`).
- **The dashboard is the single source of truth for status.** Detail sections
  below carry the problem description and proposed fix only; they do not repeat
  triage or work status.
- **Update the dashboard in the same commit as the fix.** A finding is not
  `done` until its fix is committed.
- **Append to the session log** at the bottom when a session ends, so the next
  session knows what moved.

### Triage status

| Value | Meaning |
|---|---|
| `untriaged` | Not yet reviewed by a human. Default for everything on first write. |
| `accepted` | Confirmed real, worth fixing. |
| `rejected` | Reviewed and deliberately not fixing. Record why in Notes. |
| `deferred` | Real, but not now. Record the trigger for revisiting in Notes. |
| `needs-verify` | Cannot be triaged until runtime behaviour is confirmed on a real machine. |

### Work status

| Value | Meaning |
|---|---|
| `todo` | Accepted, not started. |
| `wip` | In progress on a branch. |
| `blocked` | Started, waiting on another finding or an external decision. |
| `done` | Fix committed and confirmed on the default branch. |
| `assumed-done` | Fix dispatched and expected to land, but not yet confirmed merged. Treat as a sanity check: re-verify against the tree before trusting it, and promote to `done` or back to `todo`. |
| `n/a` | No work applies (rejected findings, or findings folded into another ID). |

### Severity

`critical` — security or data loss. `high` — user-visible breakage.
`medium` — wrong behaviour in a narrow case, or a meaningful perf cost.
`low` — noise, style, latent footgun.

---

## Dashboard

### Security

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| S1 | aactivator sources any `activate.fish` found above `$PWD` | critical | accepted | assumed-done | PRJ-1 |
| S2 | Login shell auto-pulls and runs `$HOME` dotfiles from remote | critical | untriaged | todo | PRJ-1 |
| S3 | Unpinned `git clone` of pyenv-virtualenv onto `PATH` at login | high | accepted | assumed-done | PRJ-1 |
| S4 | `install_aqua` runs `go install @latest` in every shell, unguarded | high | untriaged | todo | PRJ-1 |
| S5 | PowerShell injection in `notification` | medium | untriaged | todo | PRJ-11 |
| S6 | Secrets held in plaintext gitignored `*_local.fish` | medium | untriaged | todo | PRJ-11 |
| S7 | `copy_command_output_clipboard` leaks temp file, replays history | medium | untriaged | todo | PRJ-11 |

### Correctness

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| C1 | `uname -o` is GNU-only; macOS ssh-agent branch never fires | high | untriaged | todo | PRJ-3 |
| C2 | `test $status` is always true in `completions_load_upstream` | high | untriaged | todo | PRJ-3 |
| C3 | `taskdepends` lives in `functions/task.fish`, never autoloads | high | untriaged | todo | PRJ-3 |
| C4 | `parallel` wrapper silently runs the wrong command when glob misses | high | untriaged | todo | PRJ-3 |
| C5 | npm logfile path collides with npm's cache dir | medium | untriaged | todo | PRJ-3 |
| C6 | `$DEVBOX_PACKAGES_DIR` unset on a fresh machine, no `type -q` guard | medium | untriaged | todo | PRJ-3 |
| C7 | `set --prepend MANPATH` does not export | medium | untriaged | todo | PRJ-3 |
| C8 | `exec fish` mid-startup drops login status | medium | untriaged | todo | PRJ-3 |
| C9 | `docker` wrapper errors on bare `docker`, active non-interactively | medium | untriaged | todo | PRJ-3 |
| C10 | `up` completion registered inside its own `functions/` file | low | untriaged | todo | PRJ-3 |
| C11 | `return (contains ...)` in pre-commit completion works by accident | low | untriaged | todo | PRJ-3 |
| C12 | tox completion errors outside a tox repo, ignores tox 4 config | low | untriaged | todo | PRJ-3 |
| C13 | `navi.fish` has no interactive or `type -q` guard | low | untriaged | todo | PRJ-3 |
| C14 | `CODEX_HOME` points at the opencode config dir | low | needs-verify | todo | PRJ-3 |
| C15 | `z-wait.fish` sorts before `zoxide.fish`, not last | low | untriaged | todo | PRJ-3 |
| C16 | lazygit `config.yml` vs `config_local.yaml` extension mismatch | low | needs-verify | todo | PRJ-3 |

### PATH and scope

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| X1 | `fish_add_path` scope inconsistent; half the calls write universal | high | accepted | blocked | PRJ-2 |
| X2 | devbox and pyenv `PATH` only applied in interactive shells | high | accepted | blocked | PRJ-2 |

### Performance

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| P1 | pyenv-virtualenv hook forks `pyenv` on every prompt | high | accepted | assumed-done | PRJ-5 |
| P2 | `(pyenv root)` forked six times at startup | medium | accepted | assumed-done | PRJ-5 |
| P3 | `is_expired` forks `date` and `stat` on every call | low | untriaged | todo | PRJ-10 |
| P4 | Three overlapping venv auto-activation mechanisms | medium | accepted | assumed-done | PRJ-5 |
| P5 | `abbr --erase (abbr --list)` runs every shell, wipes earlier abbrs | low | untriaged | todo | PRJ-3 |
| P6 | Install logs append forever, never rotated | low | untriaged | todo | PRJ-6 |
| P7 | No startup benchmark harness; perf claims unverifiable | medium | untriaged | todo | PRJ-4 |

### Robustness and fallback

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| R1 | Missing-tool warnings print to stdout on every interactive shell | medium | untriaged | todo | PRJ-6 |
| R2 | No fish version floor check or graceful degradation | medium | untriaged | todo | PRJ-7 |
| R3 | `exit` used inside function bodies instead of `return` | medium | needs-verify | todo | PRJ-3 |
| R4 | Backgrounded `fish -c` blocks interpolate paths unquoted | medium | untriaged | todo | PRJ-6 |
| R5 | `main`/`install`/`extend` leak into the global function namespace | low | untriaged | todo | PRJ-6 |

### Stale patterns

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| T1 | Oh My Fish is effectively unmaintained | medium | untriaged | todo | PRJ-8 |
| T2 | bobthefish is a synchronous, git-heavy prompt | medium | untriaged | todo | PRJ-8 |
| T3 | `expand` plugin superseded by native fish 3.6+ `abbr` | low | untriaged | todo | PRJ-8 |
| T4 | `forgit` does not need OMF | low | untriaged | todo | PRJ-8 |
| T5 | `aws-okta` archived upstream | low | untriaged | todo | PRJ-8 |
| T6 | pre-commit completion shells out to python + PyYAML | low | untriaged | todo | PRJ-8 |
| T7 | GNU-only flags in `abbr.fish` break on macOS | low | untriaged | todo | PRJ-7 |

### Housekeeping and gaps

| ID | Title | Severity | Triage | Work | Project |
|---|---|---|---|---|---|
| H1 | No `fish -n` syntax check in pre-commit | medium | untriaged | todo | PRJ-9 |
| H2 | No unit tests for pure helpers | medium | untriaged | todo | PRJ-9 |
| H3 | Universal variables are untracked, undiffable machine state | medium | untriaged | todo | PRJ-2 |
| H4 | No keybinding conflict registry | low | untriaged | todo | PRJ-12 |
| H5 | Fresh-machine bootstrap order undocumented | low | untriaged | todo | PRJ-12 |
| H6 | No OSC 7 / OSC 133 terminal integration | low | untriaged | todo | PRJ-12 |
| H7 | No `fish_greeting` suppression; no umask/perm check on state dirs | low | untriaged | todo | PRJ-12 |
| H8 | Self-cancelling rule in `.config/fish/.gitignore` | low | untriaged | todo | PRJ-12 |
| H9 | `docs/solutions/` referenced by AGENTS.md but absent and gitignored | low | untriaged | todo | PRJ-12 |

---

## Details

### Security

#### S1 — aactivator sources any `activate.fish` found above `$PWD`

`conf.d/aactivator.fish:7,33`. `_activate_venv` fires on every `PWD` change,
walks upward from the current directory, and `source`s the first `activate.fish`
it finds. There is no ownership check, allowlist, or prompt, so `cd` into a
cloned repository is enough to execute attacker-controlled fish code.

Proposed fix: delete in favour of direnv, which is already installed and
requires an explicit `direnv allow` per directory. If the pattern is kept,
require the file to be owned by the current user and recorded in an allowlist.

**Triage decision (2026-09-13):** accepted, deprecate aactivator. It is a
weaker, unsandboxed duplicate of two mechanisms already in the tree:
pyenv-virtualenv (activation requires the venv to have been created via
`pyenv virtualenv` and selected via `.python-version` — both deliberate,
one-time commands, no directory-walk) and direnv (`.envrc` is hash-pinned by
`direnv allow`, re-prompts on any edit). Removing aactivator loses no
capability, since either alternative already auto-activates on `cd`. Folds
into P4 — once this lands, P4 drops from three overlapping mechanisms to two
kept by choice.

#### S2 — Login shell auto-pulls and runs `$HOME` dotfiles from remote

`conf.d/05-env.fish:28-36`. Every login shell backgrounds a `git fetch`,
`git pull`, and `git submodule update --init` inside `$HOME`. A compromised
remote or a force-push lands executable dotfiles and submodule content that runs
on the next shell with no review step. Secondary problems: no lock, so
concurrent logins race on the same `.git`; and the pull is not `--ff-only`.

Proposed fix: fetch and notify only, leaving the merge to a deliberate command.
If auto-merge is kept, use `--ff-only` and take a lock.

#### S3 — Unpinned `git clone` of pyenv-virtualenv onto `PATH` at login

`conf.d/20-virtualenv.fish:84`. Clones `pyenv/pyenv-virtualenv` at default
branch HEAD, unverified, then puts its shims on `PATH`.

Proposed fix: pin a tag, or install via aqua alongside the other pinned tools.

**Triage decision (2026-09-13):** accepted. pyenv-virtualenv tags releases as
`v1.2.x`, so pin with `--branch <tag> --depth 1`, or move the install to
`.config/aqua/aqua.yaml` where the version lives with the other pinned tools.

#### S4 — `install_aqua` runs `go install @latest` in every shell, unguarded

`conf.d/20-go.fish:19`. `type -q aqua; or install_aqua` sits outside both the
login and interactive guards, so any shell without aqua on `PATH` performs a
blocking network install of unpinned HEAD, including non-interactive subshells.
This contradicts the login/interactive cost model the rest of the tree follows.

Proposed fix: move behind `status --is-login`, pin the version, and log rather
than block.

#### S5 — PowerShell injection in `notification`

`functions/notification.fish:25-26`. `$titleText = "'$titleText'"` interpolates
the argument directly into a PowerShell string literal. A title containing `"`
or `$(...)` escapes and executes.

Proposed fix: pass values as arguments or via environment rather than splicing
into the script body.

#### S6 — Secrets held in plaintext gitignored `*_local.fish`

`conf.d/nvim.fish:3` exports `CODECOMPANION_CLAUDE_TOKEN`, populated by a
gitignored `nvim_local.fish`. The pattern puts API tokens in plaintext on disk.
`sops` is already installed via devbox and unused for this.

Proposed fix: sops-backed env loading, or the OS keychain.

#### S7 — `copy_command_output_clipboard` leaks temp file, replays history

`functions/copy_command_output_clipboard.fish:8-11`. The `mktemp` file holding
full command output is never removed, so output — potentially secrets — persists
in a shared temp directory. The function also re-executes the last history entry
via `fish -c`, which is destructive if that entry was destructive. `pbcopy` is
the only clipboard backend, so it is a no-op on Linux and WSL.

Proposed fix: trap-style cleanup, confirm before replaying history, and detect
`wl-copy`/`xclip`/`clip.exe` as fallbacks.

### Correctness

#### C1 — `uname -o` is GNU-only; macOS ssh-agent branch never fires

`conf.d/05-ssh_agent.fish:3`. macOS `uname` has no `-o`, so the command errors
and prints nothing, making the test `test = Darwin`, which itself errors and
evaluates false. The macOS path that skips `keychain` has therefore never run.

Proposed fix: `test (uname -s) = Darwin`.

#### C2 — `test $status` is always true in `completions_load_upstream`

`functions/completions_load_upstream.fish:10`. `test 1` and `test 0` are both
true, because `test` with a single non-empty string argument succeeds. The
branch always runs. When `contains` finds nothing, `$this_dir` is empty and
`set --erase search_paths[$this_dir]` becomes an invalid index, printing an
error during tab completion.

Proposed fix: `if test $status -eq 0`, or check `set -q this_dir`.

#### C3 — `taskdepends` lives in `functions/task.fish`, never autoloads

`functions/task.fish`. Fish autoloads `functions/<name>.fish` keyed on the
function name being called. The file defines only `taskdepends`, so it is never
loaded by an invocation of `taskdepends`.

Proposed fix: rename to `functions/taskdepends.fish`.

#### C4 — `parallel` wrapper silently runs the wrong command when glob misses

`functions/parallel.fish:2-3`. If the `/nix/store/*-parallel-2*/bin/parallel`
glob matches nothing, `$bin[1]` is empty and `command $bin[1] $argv` collapses
to `command $argv`, executing the user's first argument as a command.

Proposed fix: guard on `set -q bin[1]`, fall back to `command parallel`, and
warn.

#### C5 — npm logfile path collides with npm's cache dir

`conf.d/20-npm.fish:12-15`. `set logfile "$XDG_CACHE_HOME/npm"` names a
directory-shaped path, and `mkdir -p (dirname $logfile)` only creates
`$XDG_CACHE_HOME`. The bun sibling in the same file does it correctly with
`bun/log.txt`.

Proposed fix: `$XDG_CACHE_HOME/npm/log.txt`.

#### C6 — `$DEVBOX_PACKAGES_DIR` unset on a fresh machine, no `type -q` guard

`conf.d/10-devbox.fish:2`. The variable comes from the gitignored generated
config. Before that file exists the append yields the literal path
`/share/fish/vendor_completions.d`. No part of the file checks `type -q devbox`.

#### C7 — `set --prepend MANPATH` does not export

`conf.d/10-devbox.fish:7`. If `MANPATH` is not already in the environment, the
prepend creates an unexported global and `man` never sees the devbox man pages.

Proposed fix: `set -gx`.

#### C8 — `exec fish` mid-startup drops login status

`conf.d/10-devbox.fish:36`. The re-exec replaces a login shell with a non-login
one, so `install` and `regenerate` silently stop running for that session.

#### C9 — `docker` wrapper errors on bare `docker`, active non-interactively

`functions/docker.fish:5`. `test $argv[1] = 'exec'` errors when `docker` is
called with no arguments, and the argument is unquoted. The wrapper is also
autoloaded in non-interactive shells and scripts, unlike `functions/eza.fish`,
which correctly falls through when stdout is not a tty.

#### C10 — `up` completion registered inside its own `functions/` file

`functions/up.fish:19`. The `complete -c up` call only executes once the file is
autoloaded, which happens on first invocation of `up`, so completion is missing
until then.

Proposed fix: move to `completions/up.fish`.

#### C11 — `return (contains ...)` in pre-commit completion works by accident

`completions/pre-commit.fish:8`. `contains` prints nothing, so the substitution
is empty and this is a bare `return`. It happens to propagate the right status.

#### C12 — tox completion errors outside a tox repo, ignores tox 4 config

`completions/tox.fish`. `cat tox.ini` runs with no existence check, and tox 4
also reads `pyproject.toml` and `tox.toml`.

#### C13 — `navi.fish` has no interactive or `type -q` guard

`conf.d/navi.fish`. Binds `\cg` unconditionally, in non-interactive shells too,
and to a function that fails if navi is absent.

Proposed fix: leave `NAVI_CONFIG` unguarded, guard the bind.

#### C14 — `CODEX_HOME` points at the opencode config dir

`conf.d/codex.fish:1` sets `CODEX_HOME=$XDG_CONFIG_HOME/opencode`. Looks like a
copy-paste from the opencode config. Needs confirmation of intent before any
change.

#### C15 — `z-wait.fish` sorts before `zoxide.fish`, not last

The prefix `z-` is intended to sort last, but `-` (0x2D) precedes `o`, so
`z-wait.fish` loads before `zoxide.fish`. No current dependency breaks, but the
stated intent is not achieved.

Proposed fix: rename to `zz-wait.fish`.

#### C16 — lazygit `config.yml` vs `config_local.yaml` extension mismatch

`conf.d/lazygit.fish`. Base config uses `.yml`, local override uses `.yaml`.
Needs confirmation of intent.

### PATH and scope

#### X1 — `fish_add_path` scope inconsistent; half the calls write universal

Calls without an explicit scope do not pick a fixed scope. Per the
`fish_add_path` docs, `--universal` is the default "if it doesn't already
exist", and the command otherwise follows "what you have already set up (e.g.
by using a global `fish_user_paths` if you have that already)". So an unscoped
call writes global when a global already exists, and universal when nothing
does.

| File | Call | Scope |
|---|---|---|
| `05-env.fish:9` | `--global` | global |
| `20-go.fish:2` | `--global` | global |
| `20-npm.fish:55` | `--global` | global |
| `20-npm.fish:57` | none | universal |
| `20-cargo.fish:3` | none | universal |
| `10-devbox.fish:5` | none | universal |
| `20-go.fish:23` | none | universal |
| `poetry.fish:2` | none | universal |
| `20-virtualenv.fish:81` | none | universal |

**Correction (2026-09-15), verified against a real machine.** The "universal"
column above is wrong for the current tree. `05-env.fish` sorts first in
`conf.d/` and line 9 passes `--global`, which creates a global
`fish_user_paths`. Every later unscoped call then follows that global. Nothing
is presently writing universal.

Observed on a real machine: global `fish_user_paths` holds 12 entries, universal
holds 4. The 12 are exactly what walking `conf.d/` in load order produces,
starting from those 4:

| Step | Effect |
|---|---|
| start | universal: `.local/bin`, `.poetry/bin`, `fzf/bin`, `cargo/bin` |
| `05-env.fish:9` `--global` | creates global: `$HOME/bin` + those 4 |
| `10-devbox.fish:5` unscoped | follows global, prepends devbox_local |
| `20-cargo.fish:3` | already present, not re-added, stays at tail |
| `20-go.fish:2,23` | go, aqua prepended |
| `20-npm.fish:55,57` | npm, bun prepended |
| `20-virtualenv.fish:81` | pyenv shims prepended |
| `poetry.fish:2` | already present, not re-added, stays at tail |

So the real defect is not "these calls write universal". It is that correct
behavior depends on an alphabetical accident. Rename `05-env.fish`, or add any
earlier-sorting `conf.d` file that calls `fish_add_path` unscoped, and every
unscoped call silently flips to universal. Same failure class as X2: it works
by luck rather than by statement.

Proposed fix: `--global` everywhere, plus a one-time `set -e -U fish_user_paths`
and a note in AGENTS.md.

**Migration hazard, found 2026-09-15.** The 4 universal entries are residue
from before `05-env.fish` carried `--global`, and they are copied into the
global at every startup. Two have no config line anywhere in the repo:

| Universal entry | Config source | Survives an erase? |
|---|---|---|
| `.local/share/cargo/bin` | `20-cargo.fish:3` | yes |
| `.poetry/bin` | `poetry.fish:2` | yes |
| `~/.local/bin` | none, `05-env.fish:9` adds `$HOME/bin`, a different dir | no |
| `~/.local/share/fzf/bin` | none, `conf.d/fzf.fish` has no `fish_add_path` | no |

Erasing the universal before adding config lines for those two removes
`~/.local/bin` (pipx, `pip --user`) and fzf's bin directory from `PATH`, with
nothing to restore them. This is the X1 complaint in its sharpest form: two
entries of a working `PATH` are not in git and not reproducible on a new
machine.

Ordered migration:

1. Add `fish_add_path --global` for `$HOME/.local/bin` (in `05-env.fish`, next
   to the existing `$HOME/bin` line) and for the fzf bin path (in
   `conf.d/fzf.fish`, outside its interactive guard).
2. Convert the unscoped call sites to `--global`.
3. Move `PATH` setup out of the interactive guards (X2).
4. Only then `set --erase --universal fish_user_paths`, per machine. Run
   `set --show fish_user_paths` first and diff the universal list against what
   config provides, in case a machine carries residue not seen here.

Alternative considered: `fish_add_path --path` manipulates `PATH` directly with
no `fish_user_paths` intermediary, which is more declarative still. Rejected for
now as the larger change: it gives up `fish_user_paths`' guarantee of sitting
ahead of the system paths, making ordering the caller's problem.

**Triage decision (2026-09-14, revised 2026-09-15):** accepted, and X1 and X2
ship together.

The original reasoning ("fixing X1 alone breaks non-interactive shells by
removing the universal crutch") was wrong, and so was the premise. The universal
holds only 4 stale entries, none of which are devbox_local or the pyenv shims.
Those paths are written by `fish_add_path` calls inside `main`, which is
interactive-only, into a *global* that dies with the shell. So a non-interactive
shell does not get them by leakage. It does not get them at all. See the revised
X2 note.

They still ship together, for a simpler reason: X1 makes the scope explicit and
X2 makes the timing explicit, and both are the same underlying defect of
`PATH` depending on circumstance rather than statement.

Universal variables are imperative machine state in a declarative tree. The
config writes them and never reads them back, so removing a config line leaves
the value on disk forever: drop a package from `devbox.json` and its nix store
path stays ahead of the real `PATH`, on that machine only, pointing at
something that no longer exists, with a clean `git diff`. Same objection as H3.

Verify current scope on each machine before migrating, since `fish_add_path`'s
no-flag default has been version-dependent:

    set --show fish_user_paths

Migration needs a one-time `set --erase --universal fish_user_paths` per
machine. Stale universal entries otherwise sit ahead of the new global ones and
the change appears to do nothing. Decision: do it by hand and document it in
the bootstrap notes (see H5) rather than leaving a stamp-guarded one-shot in
`conf.d/` forever.

**Blocked on:** the in-flight PRs for S3/P2 and S1/P1, which edit
`20-virtualenv.fish`. Land those first to avoid conflicts. P2 also removes the
only subprocess this change would make unconditional.

#### X2 — devbox and pyenv `PATH` only applied in interactive shells

`conf.d/10-devbox.fish` and `conf.d/20-virtualenv.fish` call `main` only under
`status --is-interactive`, so devbox packages and pyenv shims are absent from
non-interactive shells except by accident, via the universal variables described
in X1. The stated model — non-interactive shells exist to get `PATH` right — is
not actually implemented; it currently works by leakage.

Proposed fix: move `PATH` setup to unconditional top-level, keep only
user-facing extras behind the interactive guard. Add a regression test that
asserts `fish -c 'echo $PATH'` contains the expected entries.

**Correction to the wording above (revised 2026-09-15).** Two errors.

First, core devbox `PATH` does reach every shell, via the generated
`conf.d/00-devbox-generated_local.fish`, which sets `export PATH=` at top level.
What is interactive-only is the `devbox_local` profile (`10-devbox.fish:5`), the
`fish_complete_path` additions, and `MANPATH`.

Second, "by accident, via the universal variables described in X1" is wrong.
Per the X1 correction, those calls write to a *global* `fish_user_paths`, which
does not survive the shell. The universal holds 4 stale entries and none of them
are devbox_local or the pyenv shims.

So this is not leakage, it is absence. A non-interactive, non-login shell runs
`conf.d/`, skips `main` in both files and skips `install` in
`20-virtualenv.fish`, and therefore has neither the devbox_local profile nor the
pyenv shims. That makes X2 a live bug rather than a latent fragility.

Verify on a real machine, since this was derived from reading rather than
running:

    fish -c 'echo $PATH' | tr " " "\n" | grep -E "pyenv|devbox_local"

Expect no output today. That is the defect.

**Triage decision (2026-09-14):** accepted, ships with X1. Line drawn on whether
an item changes what a command resolves to:

| Item | Scope |
|---|---|
| devbox global `PATH` | unconditional (already is) |
| devbox_local `bin` | unconditional |
| pyenv shims | unconditional |
| `MANPATH` | unconditional, and use `set -gx` to fix C7 at the same time |
| `fish_complete_path` | interactive only |
| abbreviations, keybindings, prompt | interactive only (already correct) |

Startup cost of going unconditional is low: everything moving is a pure builtin
(`set --append`, `fish_add_path`, `set --prepend`). The only subprocess is
`(pyenv root)`, which P2 caches. Confirm with P7 once that harness exists.

### Performance

#### P1 — pyenv-virtualenv hook forks `pyenv` on every prompt

`conf.d/20-virtualenv.fish:40`. `_pyenv_virtualenv_hook --on-event fish_prompt`
runs `pyenv activate`, a shell script, before every prompt.

Proposed fix: switch to `--on-variable PWD`, or drop entirely in favour of
direnv. Measure with PRJ-4 before and after.

**Triage decision (2026-09-13):** delete the hook outright, do not downgrade it
to `--on-variable PWD`. pyenv's shims already resolve `python`/`pip`/`pytest`
per-directory by reading `.python-version` at exec time, with no hook and no
prompt cost. The hook is not what makes commands resolve. Its only marginal
value is setting `VIRTUAL_ENV`, the prompt indicator, and tools keying off that
variable. Keep the shim `PATH` setup (lines 21-24) and the `pyenv` wrapper
function so manual `pyenv activate` still works.

**Dependency, outside this audit's scope:** the hook is what currently sets
`VIRTUAL_ENV`. If the neovim Python LSP resolves its interpreter by inheriting
`PATH` or `VIRTUAL_ENV` from the launching shell, removing the hook degrades
it. Correct fix lives in the neovim config, not here: resolve an interpreter
path per `root_dir` (`$VIRTUAL_ENV`, then `.venv/bin/python`, then
`poetry env info --path`, then `pyenv which python`). A shim path such as
`~/.pyenv/shims/python` cannot work for an LSP, since it is a dispatcher
script with no `pyvenv.cfg` or `site-packages` beside it.

#### P2 — `(pyenv root)` forked six times at startup

`conf.d/20-virtualenv.fish:12,15,21,24,81,83`. Cache once into a local.

#### P3 — `is_expired` forks `date` and `stat` on every call

`functions/is_expired.fish`. Two subprocesses per call, roughly six calls per
login. A rolling marker file compared with `test -nt`, or fish 4's `path mtime`,
removes both.

#### P4 — Three overlapping venv auto-activation mechanisms

aactivator hooks `PWD`, pyenv-virtualenv hooks `fish_prompt`, direnv hooks the
prompt as well. Each pays a per-event cost and they can fight over the same
virtualenv. Consolidate on one.

Worked example of the fighting, plausible from the source but not confirmed at
runtime: `cd` into a project with a plain `.venv`. aactivator fires on the
`PWD` change and sets `VIRTUAL_ENV`. The next prompt draw runs
`_pyenv_virtualenv_hook`, which sees `VIRTUAL_ENV` non-empty, tries
`pyenv activate --quiet`, fails because that venv is not pyenv-managed, and
falls through to `pyenv deactivate --quiet` against the venv aactivator just
set up.

**Triage decision (2026-09-13):** resolved by S1 and P1 together rather than as
separate work. Deleting aactivator and the pyenv prompt hook leaves pyenv shims
(exec-time, no hook) plus direnv (opt-in per directory, hash-pinned by
`direnv allow`). Two mechanisms kept deliberately, not three overlapping by
accident.

#### P5 — `abbr --erase (abbr --list)` runs every shell, wipes earlier abbrs

`conf.d/abbr.fish:2`. Also erases any abbreviation defined by an alphabetically
earlier conf.d file, and errors when the list is empty.

#### P6 — Install logs append forever, never rotated

`$XDG_STATE_HOME/devbox/install.log`, `$XDG_CACHE_HOME/cargo-install.log`, and
the npm log all use `>>` with no truncation.

#### P7 — No startup benchmark harness; perf claims unverifiable

Nothing in the repo measures startup. `fish --profile-startup` exists but is not
wired up, so the "~100 ms saved" claim in `AGENTS.md` cannot be re-checked or
defended against regression.

### Robustness and fallback

#### R1 — Missing-tool warnings print to stdout on every interactive shell

`conf.d/05-ssh_agent.fish:9`, `conf.d/direnv.fish:4` (note the double space in
`'direnv  is not installed'`), `conf.d/poetry.fish:8`. These belong on stderr,
once per login, with an opt-out.

#### R2 — No fish version floor check or graceful degradation

The tree uses `path dirname` (3.5+), `fish_add_path --move` (3.4+),
`bind --sets-mode`, and `fzf --fish` (fzf 0.48+). On an older machine this
produces a cascade of errors with no indication of the cause.

Proposed fix: a `conf.d/00-compat.fish` that checks `$version` against a
documented floor and warns once.

#### R3 — `exit` used inside function bodies instead of `return`

`conf.d/direnv.fish`, `conf.d/poetry.fish`, `conf.d/fuck.fish`,
`conf.d/20-cargo.fish`, `conf.d/05-ssh_agent.fish`. Fish documents different
behaviour for `exit` inside a sourced file (skip the rest of the file) versus
inside a function (exit the shell). Which applies to a function defined and
called within a sourced conf.d file needs confirming on a real fish. Either way
`return` is unambiguous.

#### R4 — Backgrounded `fish -c` blocks interpolate paths unquoted

`conf.d/10-devbox.fish`, `conf.d/20-cargo.fish`, `conf.d/20-npm.fish`,
`conf.d/20-virtualenv.fish`. Any space in an `$XDG_*` path breaks them.
`20-cargo.fish` additionally echoes failures to the terminal asynchronously,
which lands on top of the prompt.

#### R5 — `main`/`install`/`extend` leak into the global function namespace

`main`, `install`, `regenerate`, `install_aqua`, `install_aqua_tools`,
`install_bun_globals`, `extend`, `extend_local` all persist for the session.
`AGENTS.md` currently documents the footgun instead of removing it.

Proposed fix: `functions --erase` at the end of each file, or unique prefixes.

### Stale patterns

#### T1 — Oh My Fish is effectively unmaintained

`conf.d/omf.fish`, plus the `.config/fish/plugins/oh-my-fish` submodule. Last
meaningful upstream activity is years old. Its installer clobbers the user's
config, which is why `omf.fish:24` has to `git checkout $current_file` to undo
the damage.

Proposed fix: fisher, or vendor the three things actually used directly into
`conf.d/`.

#### T2 — bobthefish is a synchronous, git-heavy prompt

`conf.d/bobthefish.fish`. Replacement candidates: tide (async, fish-native) or
starship.

#### T3 — `expand` plugin superseded by native fish 3.6+ `abbr`

Native `abbr` now supports `--regex`, `--function`, `--set-cursor`, and
`--command`. The plugin also forces the `\t` rebinding hack in
`functions/fish_user_key_bindings.fish`.

#### T4 — `forgit` does not need OMF

Ships standalone; can be sourced directly.

#### T5 — `aws-okta` archived upstream

`completions/aws-okta.fish`. Delete if unused, otherwise migrate to aws-vault or
AWS SSO.

#### T6 — pre-commit completion shells out to python + PyYAML

`completions/pre-commit.fish:38`. Depends on whichever python is on `PATH`
having PyYAML installed. `yq` is a direct replacement.

#### T7 — GNU-only flags in `abbr.fish` break on macOS

`du --max-depth`, `netstat --listening --program --numeric`, `pgrep -fau`,
`pstree -g`, `time -f`. Either branch on platform or document the tree as
Linux-only.

### Housekeeping and gaps

#### H1 — No `fish -n` syntax check in pre-commit

`.pre-commit-config.yaml` has no fish hooks, despite `AGENTS.md` instructing
humans to run `fish -n` manually. Most findings in the Correctness section are
the kind CI catches.

#### H2 — No unit tests for pure helpers

`is_expired`, `up`, `eza`, and `completions_load_upstream` are testable with
fishtape.

#### H3 — Universal variables are untracked, undiffable machine state

`fish_variables` is gitignored, so part of the live configuration is outside
version control and cannot be diffed between machines. Related to X1.

#### H4 — No keybinding conflict registry

`\cf` (pay-respects), `\cg` (navi), `\cx` (expand), `\ct`/`\cr`/`\ec` (fzf). No
single place lists them, so the next tool that binds something wins silently.

#### H5 — Fresh-machine bootstrap order undocumented

Chicken-and-egg: devbox provides most tools, but `10-devbox.fish` depends on a
generated file that requires devbox to produce.

#### H6 — No OSC 7 / OSC 133 terminal integration

Missing cwd reporting and prompt marks, which breaks new-tab-in-same-directory
and shell-aware scrollback navigation.

#### H7 — No `fish_greeting` suppression; no umask/perm check on state dirs

#### H8 — Self-cancelling rule in `.config/fish/.gitignore`

Lines 14-16: `!/conf.d/*devbox-generated_local.fish` is immediately followed by
`/conf.d/00-devbox-generated_local.fish`. Net effect is ignored; the negation is
dead.

#### H9 — `docs/solutions/` referenced by AGENTS.md but absent and gitignored

`AGENTS.md` names `docs/solutions/` as the project-scoped learnings store, but
the directory does not exist and the root opt-in `.gitignore` does not whitelist
`docs/`, so writes there are silently untracked.

---

## Projects

Each project is independently shippable. `Findings` lists the IDs it closes.

| ID | Project | Findings | Effort | Triage | Work |
|---|---|---|---|---|---|
| PRJ-1 | Close the arbitrary-code-execution paths | S1, S2, S3, S4 | M | untriaged | todo |
| PRJ-2 | PATH scope unification | X1, X2, H3 | M | untriaged | todo |
| PRJ-3 | Correctness sweep | C1-C16, P5, R3 | M | untriaged | todo |
| PRJ-4 | Startup profiling harness | P7 | S | untriaged | todo |
| PRJ-5 | Eliminate per-prompt cost | P1, P2, P4 | M | untriaged | todo |
| PRJ-6 | Guard, warn, and log standard | R1, R4, R5, P6 | S | untriaged | todo |
| PRJ-7 | Version and platform compat layer | R2, T7 | M | untriaged | todo |
| PRJ-8 | De-OMF | T1, T2, T3, T4, T5, T6 | L | untriaged | todo |
| PRJ-9 | CI for fish | H1, H2 | M | untriaged | todo |
| PRJ-10 | Completion-generation helper | P3 | S | untriaged | todo |
| PRJ-11 | Secret and temp-file handling | S5, S6, S7 | M | untriaged | todo |
| PRJ-12 | Housekeeping | H4, H5, H6, H7, H8, H9 | S | untriaged | todo |

### Suggested order

PRJ-1 and PRJ-2 first: they carry the real risk. PRJ-3 is cheap and removes the
noise that hides genuine failures. PRJ-4 must land before PRJ-5, otherwise the
perf work is guesswork again.

---

## Session log

| Date | Session | What moved |
|---|---|---|
| 2026-09-13 | Initial audit | Full static audit of `.config/fish/`. 53 findings recorded across 12 projects. Nothing triaged, nothing fixed. |
| 2026-09-15 | X1/X2 correction | Real `set --show fish_user_paths` output disproved two claims in X1 and X2. Unscoped `fish_add_path` follows an existing global rather than always writing universal, so nothing currently writes universal and the defect is dependence on `05-env.fish` sorting first. Non-interactive shells do not get devbox_local or pyenv shims by leakage, they do not get them at all. Also found two `PATH` entries (`~/.local/bin`, fzf bin) that exist only as universal residue with no config line, making the planned universal erase destructive until they are added. Correction sent to the in-flight X1/X2 session. |
| 2026-09-13 | Venv triage | Triaged S1, S3, P1, P2, P4 as accepted and dispatched them as two PRs to separate sessions, so all five are `assumed-done` pending confirmation. PR 1: pin the pyenv-virtualenv clone, cache `(pyenv root)`. PR 2: delete aactivator, delete the per-prompt pyenv hook. Those sessions branched from the default branch and cannot see this doc, so their commits will not update these rows. Verify against the tree before trusting the statuses. Follow-up not yet dispatched: neovim Python LSP interpreter resolution, which PR 2 may block on (see P1). |
