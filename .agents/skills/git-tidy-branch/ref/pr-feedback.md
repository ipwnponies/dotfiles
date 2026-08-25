# Variant: Absorbing self-fix commits into history

Use this variant whenever the branch has one or more self-fix commits: commits whose real
job is to fix, correct, revise, or close a gap in something an *earlier commit in this same
range* introduced. The classic shape is "address feedback"/"fix review"/"nit" commits
trailing at the tip, but the same pattern shows up anywhere in the range and in any file
type — a `docs:` commit revising a plan or spec an earlier commit added is the identical
case to a `fix:` commit correcting code from two commits back. Don't read "PR feedback" or
"trailing" in this file's name/examples as a scope limit; the mechanics below (blame-to-
target, hunk extraction, autosquash) work the same for a self-fix found in the middle of
the range or in a non-code file.

The goal: absorb each self-fix hunk into the specific earlier commit it corrects. The final
history looks as if the developer (or, on this branch, whatever produced it — SDD, a
review pass, an earlier assistant session) got it right the first time.

## Step F1: Identify self-fix commits

```bash
git log --oneline $MERGE_BASE..HEAD
```

Read every commit's message and diff, not just the ones at the tip — a self-fix can sit
anywhere in the range. Typical messages: "address PR feedback", "fix review comments",
"nit", "wip", "more fixes", "resolve doc-review findings", "close plan-review gaps",
"correct X". But the type prefix isn't reliable on its own — a `feat:` or `docs:` commit
whose diff only makes sense as "revise what an earlier commit in this range already added"
is a self-fix too; judge by what the diff does to earlier content, not by the label.
Identify how many there are (call it N) and whether they're contiguous at the tip or
scattered through the range — scattered self-fixes still get mapped and absorbed the same
way (Step F4), they just don't have a single contiguous "clean baseline" to diff against
in Step F2, so treat that step as identifying the *set* of non-self-fix commits instead of
one prefix/suffix split point.

## Step F2: Find the clean baseline

```bash
# SHA of the last clean commit (before any feedback commits)
# git log is newest-first, so the Nth+1 line is the last clean commit
CLEAN_SHA=$(git log --oneline $MERGE_BASE..HEAD | sed -n "$((N+1))p" | cut -d' ' -f1)

# Validate — if empty, all commits on the branch are feedback commits (nothing to absorb into)
if [ -z "$CLEAN_SHA" ]; then
  echo "Error: all $N commits appear to be feedback commits; no clean baseline to absorb into."
  exit 1
fi
```

This shortcut only applies when the self-fixes are contiguous at the tip. When they're
scattered through the range instead, there's no single `CLEAN_SHA` — go straight to Step F4
and map every self-fix hunk to its target commit directly; the target commits collectively
serve the role `CLEAN_SHA` plays below.

## Step F3: Check for lint/config timeline

Scan for commits that introduce lint or style rules:

```bash
git log --oneline $MERGE_BASE..$CLEAN_SHA -- \
  '*.eslintrc*' '*flake8*' 'pyproject.toml' 'ruff.toml' \
  '.rubocop.yml' '.pre-commit-config.yaml' 'setup.cfg' '.pylintrc'
```

Note which commits introduce rule changes. A feedback hunk whose target commit predates a
lint-rule commit should be absorbed into that lint-rule commit or kept after it — never
squashed into a commit that predates the rule being introduced. That would make the history
lie: it would show code "correctly" following rules that didn't exist yet.

## Step F4: Map each feedback hunk to its target commit

For each hunk in each feedback commit, find which earlier commit originally introduced the
lines being changed:

```bash
# Get the diff of feedback commits
git diff $CLEAN_SHA..HEAD

# For a hunk touching file F at lines L1-L2, blame the clean baseline:
git blame -L <L1>,<L2> $CLEAN_SHA -- <file>
```

The blame output shows which commit SHA introduced each line. That commit is the target for
this fixup hunk.

**Pure-addition hunks** (only `+` lines, no `-` lines to blame): there is no pre-existing line
to blame. Instead blame the lines immediately surrounding the insertion point — the lines just
above and below — to identify which commit owns the context. That commit is the target.

Do this for every hunk across all feedback commits. Build a mapping:
```
feedback hunk A → target: "refactor: extract validation helper" (abc1234)
feedback hunk B → target: "fix: reject expired tokens" (def5678)
feedback hunk C → target: same "fix: reject expired tokens" (def5678)
```

## Step F5: Split feedback commits and create fixup commits

For each target commit, collect the feedback hunks that belong to it. Use the same
`commit-plan.json` + `extract_hunks.py` approach to extract those specific hunks, then
commit them with a `fixup!` prefix that exactly matches the start of the target message:

```bash
git commit -m "fixup! refactor: extract validation helper"
git commit -m "fixup! fix: reject expired tokens"
```

`git rebase --autosquash` uses prefix matching, so the message must start exactly with
`fixup! <target-message>`.

## Step F6: Rebase with autosquash

First capture a durable backup so you can always get back:
```bash
git update-ref refs/tidy-backup/$(date +%Y%m%d-%H%M%S) HEAD
FEEDBACK_BACKUP=$(git rev-parse HEAD)
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash $MERGE_BASE
```

git automatically positions each `fixup!` commit directly after its target and marks it as
`fixup` in the todo list.

## Step F7: Resolve conflicts

When a fixup absorbs into an earlier commit, subsequent commits replay on top of the changed
state. A conflict means a later commit modified the same lines.

Read `ref/conflict-resolution.md` for the full protocol. The key: don't choose sides
mechanically — understand the purpose of the conflicting commit and re-implement it in the
new context.

Example: feedback fixes logic in `get_user()`. A later commit then reformats it per a new
lint rule. After autosquash, the lint commit conflicts because the baseline changed.
Resolution: re-apply the formatting to the new (fixed) version of `get_user()`.

**Bail-out:** if a conflict is unresolvable, abort cleanly — never leave a half-finished rebase:
```bash
git rebase --abort                       # returns to FEEDBACK_BACKUP state
git reset --hard $FEEDBACK_BACKUP        # belt-and-suspenders if abort is unavailable
```

## Step F8: Verify

```bash
git log --oneline
git diff --quiet $FEEDBACK_BACKUP HEAD && echo "tree identical" || echo "DRIFT — investigate"
```

Absorbing feedback must not change the final tree — the end state is identical, only the
commit boundaries move. `git diff --quiet $FEEDBACK_BACKUP HEAD` (exit 0) proves it.
The feedback commits should no longer appear as separate entries. If drift is reported,
something was lost or doubled during conflict resolution — `git reset --hard
$FEEDBACK_BACKUP` and retry.
