# Navi Cheat Files — Agent Guide

Docs: https://github.com/denisidoro/navi/blob/master/docs/cheatsheet/syntax/README.md

## File Format

```
% tag1, tag2          ← section header (required before commands)

# Description         ← shown in navi UI
command <var>         ← executable command; <var> is a variable placeholder

$ var: <cmd>          ← variable definition: cmd output populates fzf picker
```

- Lines starting `%`: section tags
- Lines starting `#`: description (paired with next command block)
- Lines starting `$`: variable definitions
- Lines starting `;`: comments (ignored by navi)
- All other non-empty lines: executable commands

## Variable Syntax

`<varname>` in commands is **literal text substitution** — happens before shell sees the command. No automatic quoting. Values with spaces/quotes will break unless escaped.

### Execution contexts

| What | Shell | Notes |
|---|---|---|
| Executable commands | `$SHELL` | Currently **fish** for this user |
| Variable definition commands (`$ var: ...`) | `$SHELL` | Currently **fish** for this user |
| `--map` | `sh` (hardcoded by navi) | Always sh, regardless of `$SHELL` |

**If user changes shell**: update all cheat file syntax and `--map` invocations to match the new shell. The key places are: command substitution syntax, string escaping builtins, and the explicit shell invoked in `--map`.

### Shell-escaping variable values

`--map` runs in `sh`. `printf '%q'` is bash-only — **do not use** directly. To use the user's shell for escaping, invoke it explicitly:

```
# Current shell is fish — uses fish string escape
$ file: fd . .. --- --map "fish -c 'read line; string escape \$line'"
```

- `read line` reads selected value from stdin (avoid `$(cat)` — subshell doesn't inherit stdin in sh)
- `string escape` produces escaping safe for the user's shell (fish)
- `\$line` — backslash prevents sh from expanding `$line`; fish receives literal `$line`
- With map escaping active, use `<var>` bare in commands (no surrounding quotes needed)

### Shell escaping: two approaches

**Approach A — pipe to escape command in variable definition** (simpler, fzf shows escaped strings):
```
# fish
$input: fd --type file '.*\.jpg' --max-depth 1 | string escape
```

**Approach B — `--map` after fzf selection** (fzf shows clean names, escaping applied after pick):
```
# fish
$ file: fd . .. --- --map "fish -c 'read line; string escape \$line'"
```

Tradeoff: A is simpler but user sees `it\'s\ a\ filename.mp4` in picker. B shows clean names.

### Variable options (after `---`)

| Option | Effect | Example |
|---|---|---|
| `--map "cmd"` | Transform selected value; cmd receives value on stdin (runs in sh) | `--map "fish -c 'read line; string escape \$line'"` |
| `--column N` | Extract Nth column | `--delimiter '\t' --column 1` |
| `--delimiter regex` | Split output into columns | `--delimiter '\t'` |
| `--header-lines N` | Skip N header lines in fzf | `--header-lines 1` |
| `--multi` | Allow multi-select in fzf | `--- --multi --expand` |
| `--expand` | Each selected line becomes separate shell argument | `--- --multi --expand` |
| `--fzf-overrides "arg"` | Pass arbitrary fzf flags | `--fzf-overrides "--no-select-1"` |
| `--prevent-extra` | Restrict to listed values only | |

### Real examples

```
# Two-column output: display human label in fzf, interpolate id only
$ item: some-cli list | parse-columns --- --delimiter '\t' --column 1

# Fixed choices with display label, interpolate code value
$ size: printf '%s\t%s\n' sm 'Small' lg 'Large' --- --delimiter '\t' --column 1

# fzf seeded with suggestions (show single suggestion but don't auto-accept single match)
$ output: echo default.txt --- --fzf-overrides "--no-select-1"

# Multi-select, each picked line becomes separate argument
$ files: fd . . --- --multi --expand

# Shell-escape after selection (fzf shows clean names). Useful for filenames with spaces or quotes.
$ file: fd . . --- --map "fish -c 'read line; string escape \$line'"
```

### Variable dependencies

```
$ b: echo "<a>/subdir"      ← implicit: references <a> value
$ b: echo "$a foo"          ← explicit: $a expands at selection time
```

## Shell-Specific Syntax (currently fish)

User's shell is **fish**. If shell changes, update all syntax below accordingly.

Command substitution in fish is `(cmd)`, NOT `$(cmd)` (bash syntax).

```fish
# correct — fish command substitution
echo (basename <file>) (some-cmd <file>)
```

**Linter/formatter warning**: Some tools strip bare `()` thinking they're empty groupings. If `(basename <file>)` becomes `basename <file>`, the command substitution is broken. Always verify fish parens are intact after any automated formatting.

## Multiline Commands

Either backslash-continuation or fenced code blocks:

```
true \
  && echo yes \
  || echo no
```

