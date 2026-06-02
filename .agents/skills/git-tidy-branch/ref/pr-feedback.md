# Variant: Absorbing PR feedback into history

Use this variant when the branch already has clean atomic commits but trailing "address
feedback", "fix review", "nit", or similar commits at the end that touch code from multiple
earlier commits.

The goal: absorb each feedback hunk into the specific earlier commit it corrects. The final
history looks as if the developer got it right the first time.

## Step F1: Identify feedback commits

```bash
git log --oneline $MERGE_BASE..HEAD
```

Feedback commits are typically at the tip and have messages like "address PR feedback",
"fix review comments", "nit", "wip", "more fixes". Identify how many there are (call it N).

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
