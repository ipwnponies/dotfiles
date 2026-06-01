---
name: git-tidy-branch
description: >
  Reorganizes messy git commits on a branch into logical, atomic, reviewer-friendly commits.
  Use this skill when the user wants to clean up their branch before code review, says things
  like "tidy my commits", "clean up branch history", "prep for PR", "reorder commits",
  "atomic commits", "my commits are a mess", "squash and reorganize", "reviewers will hate
  my git log", "absorb PR feedback into commits", "squash feedback into history", "clean up
  after review", or "incorporate review changes". Handles all starting states: one giant
  commit, dozens of WIP commits, wrong-order commits, or clean history with trailing PR
  feedback commits that need absorbing back into their target commits. Produces a history
  where each commit is coherent in isolation and tells a clear story. Operates autonomously.
---

Reorganize messy branch history into clean, atomic, reviewer-friendly commits. Operate
autonomously: analyze → decide → execute. Only pause for user input when you've exhausted
options and guessing wrong would be worse than asking.

The story to tell a reviewer: first why (refactor/setup), then the test, then the change,
then cleanup.

## Step 0: Preconditions — never rewrite history over unsaved work

```bash
git status --porcelain          # MUST be empty
git symbolic-ref -q HEAD        # MUST succeed (not detached)
```

If the tree is dirty, stop and tell the user to commit or stash first — a soft reset
would blend their uncommitted work into the rewrite and it cannot be recovered from the
backup (the backup only captures committed history). The generated script re-checks this
and refuses to run, but check up front so you don't waste effort building a plan.

The generated script also refuses if the range contains **merge commits** (a soft reset
flattens them, destroying topology). If `git rev-list --merges $MERGE_BASE..HEAD` is
non-empty, this skill is the wrong tool — say so rather than mangling the history.

## Step 1: Find the base

Try common base branch names:
```bash
git for-each-ref --format='%(refname:short)' refs/heads/ | grep -E '^(main|master|develop|trunk)$' | head -1
```

If the repo has exactly one remote tracking branch that predates this branch, use that.
Only ask the user if genuinely ambiguous (multiple candidates, no clear winner).

```bash
BASE=<base-branch>
MERGE_BASE=$(git merge-base HEAD $BASE)
```

## Step 2: Assess the branch

```bash
git log --oneline $MERGE_BASE..HEAD
git diff $MERGE_BASE..HEAD --stat
git diff $MERGE_BASE..HEAD
```

Classify silently:
- **Single commit**: needs splitting
- **WIP mess**: many small commits to be regrouped
- **Wrong order**: commits exist but sequence is wrong
- **Mixed**: combination

## Step 3: Classify changes and decide the commit plan

Read the full diff. For each changed file and hunk, classify:

| Type | Signs |
|------|-------|
| **refactor** | Same behavior — renames, extractions, moved functions, no new logic |
| **test** | Files under `test*/`, `spec*/`, `*_test.*`, `*_spec.*`, or fixtures |
| **fix/feat** | New logic, conditionals, bug corrections, new behavior |
| **chore** | Config, `requirements*.txt`, `package*.json`, `*.lock`, CI/CD, build |
| **docs** | README, inline comments, docstrings, changelogs |
| **style** | Formatter-only — whitespace, quote style, trailing commas |

Index hunks 0-based in the order they appear in `git diff` output. A single file may need
splitting across commits if it contains both refactor and logic changes.

**Decide commit order** (what reads well for a reviewer):
1. `refactor` — restructuring with no behavior change (makes subsequent diffs cleaner)
2. `test` — tests before the code they test (TDD signal)
3. `feat`/`fix` — the actual change
4. `chore`/`docs` — housekeeping

Merge trivially small groups into adjacent commits when they're clearly part of the same
concern. Don't create a commit for a single blank-line change.

## Step 4: Write commit-plan.json

Write to a scratch dir **outside the repo** so the plan, generated script, and patch
files never dirty the working tree (the precondition check would trip on them, and a
stray `git add .` could leak them into history):

```bash
WORK=$(mktemp -d)
```

Write the plan to `$WORK/commit-plan.json`:

```json
{
  "base_ref": "<base-branch-name>",
  "commits": [
    {
      "message": "refactor: extract validation helper",
      "hunks": [
        {"file": "src/auth.py", "hunk_indices": [0, 1]},
        {"file": "src/utils.py"}
      ]
    },
    {
      "message": "test: add unit tests for validation helper",
      "hunks": [
        {"file": "tests/test_auth.py"}
      ]
    },
    {
      "message": "fix: reject expired tokens on refresh endpoint",
      "hunks": [
        {"file": "src/auth.py", "hunk_indices": [2]},
        {"file": "src/routes.py"}
      ]
    }
  ]
}
```

Rules:
- Omit `hunk_indices` when taking the whole file
- Use the **new** filename for renamed files (the `b/` side in `diff --git a/old b/new`)
- Conventional Commits format: `type(scope): imperative summary` ≤72 chars
- `base_ref` must be the branch name (e.g. `main`), not a SHA — the script computes merge-base

## Step 5: Generate the staging script

```bash
SKILL_SCRIPT=$(find ~/.claude/skills -name extract_hunks.py 2>/dev/null | head -1)
python3 "$SKILL_SCRIPT" "$WORK/commit-plan.json"
```

This produces `$WORK/stage-and-commit.sh` (and `$WORK/patches/`). Inspect it briefly
before running. The script self-guards: it checks the tree is clean, refuses on merge
commits or detached HEAD, writes a durable backup ref under `refs/tidy-backup/<ts>`, and
on **any** failure auto-restores to the original tip via an EXIT trap.

## Step 6: Execute

```bash
bash "$WORK/stage-and-commit.sh"
```

The script finishes with a **tree-identity gate**: `git diff --quiet $TIDY_BACKUP HEAD`.
If the rewritten history does not reproduce the original tree byte-for-byte (a hunk was
dropped, misplaced, or mangled), it prints the offending stat, hard-resets to the backup,
and exits non-zero. A clean exit means the content is provably unchanged.

If `git apply --cached` fails (context mismatch) the script aborts and auto-restores.
Retry by editing the plan, or apply that one file with a fuzzier match:
```bash
git apply --cached --ignore-whitespace --recount "$WORK/patches/<file>.patch"
```

If that still fails, stage the file manually:
```bash
git add -p <file>   # select the right hunks interactively
```

Only ask the user for help if both automated approaches fail and you can't determine which
hunks belong where without their domain knowledge.

## Step 7: Verify

The script already proved tree identity. Confirm the shape independently:

```bash
git log --oneline
git diff --quiet $TIDY_BACKUP HEAD && echo "tree identical" || echo "DRIFT — do not ship"
```

`git diff --quiet $TIDY_BACKUP HEAD` (exit 0) is the authoritative check — it proves every
byte of the original tree is preserved. `--stat` is **not** sufficient: it can match while
hunks landed in the wrong commit or content was whitespace-mangled. `$TIDY_BACKUP` is
printed by the script; it also persists at `refs/tidy-backup/<ts>`.

Clean up the scratch dir (keep the backup ref until the branch is pushed and reviewed):
```bash
rm -rf "$WORK"
```

---

## Variant: Absorbing PR feedback into history

Use this variant when the branch already has clean atomic commits but trailing "address
feedback", "fix review", "nit", or similar commits at the end that touch code from multiple
earlier commits.

The goal: absorb each feedback hunk into the specific earlier commit it corrects. The final
history looks as if the developer got it right the first time.

### Step F1: Identify feedback commits

```bash
git log --oneline $MERGE_BASE..HEAD
```

Feedback commits are typically at the tip and have messages like "address PR feedback",
"fix review comments", "nit", "wip", "more fixes". Identify how many there are (call it N).

### Step F2: Find the clean baseline

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

### Step F3: Check for lint/config timeline

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

### Step F4: Map each feedback hunk to its target commit

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

### Step F5: Split feedback commits and create fixup commits

For each target commit, collect the feedback hunks that belong to it. Use the same
`commit-plan.json` + `extract_hunks.py` approach to extract those specific hunks, then
commit them with a `fixup!` prefix that exactly matches the start of the target message:

```bash
git commit -m "fixup! refactor: extract validation helper"
git commit -m "fixup! fix: reject expired tokens"
```

`git rebase --autosquash` uses prefix matching, so the message must start exactly with
`fixup! <target-message>`.

### Step F6: Rebase with autosquash

First capture a durable backup so you can always get back:
```bash
git update-ref refs/tidy-backup/$(date +%Y%m%d-%H%M%S) HEAD
FEEDBACK_BACKUP=$(git rev-parse HEAD)
git rebase -i --autosquash $MERGE_BASE
```

git automatically positions each `fixup!` commit directly after its target and marks it as
`fixup` in the todo list. Save and close the editor (or run non-interactively with
`GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash $MERGE_BASE`).

### Step F7: Resolve conflicts

When a fixup absorbs into an earlier commit, subsequent commits replay on top of the changed
state. A conflict means a later commit modified the same lines.

Follow the **Intelligent conflict resolution** protocol below. The key: don't choose sides
mechanically — understand the purpose of the conflicting commit and re-implement it in the
new context.

Example: feedback fixes logic in `get_user()`. A later commit then reformats it per a new
lint rule. After autosquash, the lint commit conflicts because the baseline changed.
Resolution: re-apply the formatting to the new (fixed) version of `get_user()`.

**Bail-out:** if a conflict is unresolvable or you've lost the thread, abort cleanly —
never leave a half-finished rebase:
```bash
git rebase --abort                       # returns to FEEDBACK_BACKUP state
git reset --hard $FEEDBACK_BACKUP        # belt-and-suspenders if abort is unavailable
```

### Step F8: Verify

```bash
git log --oneline
git diff --quiet $FEEDBACK_BACKUP HEAD && echo "tree identical" || echo "DRIFT — investigate"
```

Absorbing feedback must not change the final tree — the end state is identical, only the
commit boundaries move. `git diff --quiet $FEEDBACK_BACKUP HEAD` (exit 0) proves it.
The feedback commits should no longer appear as separate entries. If drift is reported,
something was lost or doubled during conflict resolution — `git reset --hard
$FEEDBACK_BACKUP` and retry.

---

## Step 8: Rebase onto latest base (optional but recommended before PR)

After history is clean, check if the base branch has moved. Unlike the steps above, this
rebase **intentionally changes the tree** (it incorporates upstream work) — so the
tree-identity gate does not apply here. The integrity check is instead "every one of my
commits survived", verified with `git range-diff` below.

Find the remote that actually hosts `$BASE` (don't assume the branch's own upstream remote
hosts it — fork workflows differ):

```bash
# Prefer the remote whose tracking branch for $BASE exists.
REMOTE=$(git for-each-ref --format='%(refname:short)' "refs/remotes/*/$BASE" \
         | head -1 | cut -d/ -f1)
REMOTE=${REMOTE:-origin}
git fetch "$REMOTE"
git rev-list HEAD.."$REMOTE/$BASE" --count
```

If the count is 0, the branch is current — skip this step.

If the count is >0, back up first, then rebase:

```bash
git update-ref refs/tidy-backup/$(date +%Y%m%d-%H%M%S) HEAD
REBASE_BACKUP=$(git rev-parse HEAD)
git rebase "$REMOTE/$BASE"
```

After it completes, confirm no commit was silently dropped or mangled:
```bash
git range-diff "$REMOTE/$BASE" $REBASE_BACKUP HEAD
```
Every original commit should map 1:1 to a rebased commit with only context shifts. An
unexpected `<` (dropped) or content change beyond the conflict you resolved means investigate.

**Do not rebase a dirty branch.** This step must come after Steps 1-7 (history cleaned up
first). Rebasing a messy branch creates two layers of complexity: conflict resolution AND
history reorganization simultaneously. Clean first, rebase second.

If conflicts arise, follow the intelligent conflict resolution protocol below. To bail out
of a conflicted rebase at any point:
```bash
git rebase --abort               # restores to REBASE_BACKUP
```

---

## Intelligent conflict resolution

When `git rebase` or `git rebase --autosquash` stops on a conflict, do NOT blindly choose
"ours" or "theirs". Instead, understand both intents and re-implement them together.

### The protocol

**1. Gather context on both sides**

```bash
# What commit is being replayed (our side — the commit currently being applied)?
git log -1 --format="%H %s%n%b" REBASE_HEAD

# What does the conflict look like?
git diff                        # shows conflict markers in all conflicted files

# What did the upstream commits (their side) change in this file?
# ORIG_HEAD is our pre-rebase tip, not the upstream. Use merge-base to find
# the divergence point, then log what upstream added between there and our target.
REBASE_ONTO=$(cat .git/rebase-merge/onto 2>/dev/null || cat .git/rebase-apply/onto 2>/dev/null)
git log --oneline $(git merge-base REBASE_HEAD "$REBASE_ONTO").."$REBASE_ONTO"
git show "$REBASE_ONTO" -- <conflicted-file>
```

Read:
- Our commit message (`REBASE_HEAD`) → our intent
- The upstream commits between merge-base and `onto` → their intent
- The conflict markers → where the two intents collide
- The surrounding code → enough context to re-implement correctly

**2. Re-implement, don't merge mechanically**

The conflict markers are a symptom, not the answer. Ask: "If a developer had both changes
in mind from the start, what would they have written?" Write that.

Common cases:

| Conflict type | Resolution approach |
|---------------|-------------------|
| Upstream renamed a function our commit calls | Update our call to the new name |
| Upstream reformatted a block our commit modifies | Apply our change to the reformatted version |
| Upstream added lines above/below code we changed | Keep both additions |
| Upstream refactored a function our commit extends | Apply our extension to the refactored version |
| Both sides changed the same logic differently | Understand which behavior is correct — ask user if domain-specific |

**3. Write the resolution directly**

Read the conflicted file, understand the full context, then write the resolved version.
Don't use `git checkout --ours/--theirs`. Write what the file should contain.

```bash
git add <resolved-file>
git rebase --continue
```

**4. When to stop and ask**

Ask the user only when:
- Both sides changed the same business logic and either behavior could be correct
- The conflict is in generated code (lock files, compiled assets) — usually take theirs
- The conflict would change observable behavior and you can't determine which is right

When asking, provide:
- Which two commits are conflicting
- What each was trying to do (quoted from commit messages)
- What the specific collision is
- Your best guess and why you're uncertain

---

## Commit message guide

```
type(scope): imperative summary     ← ≤72 chars, no trailing period
```

**Types**: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `build`, `ci`, `perf`

---

## Edge cases

**Binary files / large assets**: whole-file only, no hunk splitting.

**Deleted files**: whole-file staging (`git add -- <path>` stages deletions too).

**Renamed files**: use the new filename in `commit-plan.json`. The script also stages the
old path so its deletion is recorded (otherwise the old file lingers and the tree diverges).

**apply failure**: try `--ignore-whitespace --recount`. If still failing, use `git add -p`.

**Recovery**: the staging script prints `$TIDY_BACKUP` and writes a durable ref. Use that —
**not** `HEAD@{1}`, which after a multi-commit rewrite points at an intermediate commit, not
the original tip.
```bash
git reset --hard $TIDY_BACKUP          # exact SHA the script printed
# or, if the shell variable is gone:
git for-each-ref refs/tidy-backup      # list backups; pick the right timestamp
git reset --hard refs/tidy-backup/<ts>
```
Backups under `refs/tidy-backup/` persist until you delete them; prune with
`git for-each-ref --format='%(refname)' refs/tidy-backup | xargs -n1 git update-ref -d`
once the branch is pushed and reviewed.
