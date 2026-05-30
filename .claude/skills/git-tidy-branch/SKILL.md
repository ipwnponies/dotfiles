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

Write this file to the repo root (or `/tmp` if root isn't writable):

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
python3 /root/.claude/skills/git-tidy-branch/scripts/extract_hunks.py commit-plan.json
```

This produces `stage-and-commit.sh`. Inspect it briefly before running.

## Step 6: Execute

```bash
bash stage-and-commit.sh
```

If `git apply --cached` fails (context mismatch), retry:
```bash
git apply --cached --ignore-whitespace --recount patches/<file>.patch
```

If that still fails, stage the file manually:
```bash
git add -p <file>   # select the right hunks interactively
```

Only ask the user for help if both automated approaches fail and you can't determine which
hunks belong where without their domain knowledge.

## Step 7: Verify

```bash
git log --oneline
git diff $MERGE_BASE..HEAD --stat
```

Diff stat must match what you saw in Step 2. If anything is missing, investigate with
`git status` and `git diff` before reporting success.

Clean up temp files:
```bash
rm -f commit-plan.json stage-and-commit.sh
rm -rf patches/
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
CLEAN_SHA=$(git log --oneline $MERGE_BASE..HEAD | sed -n "${N}p" | cut -d' ' -f1)
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

```bash
git rebase -i --autosquash $MERGE_BASE
```

git automatically positions each `fixup!` commit directly after its target and marks it as
`fixup` in the todo list. Save and close the editor (or run non-interactively with
`GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash $MERGE_BASE`).

### Step F7: Resolve conflicts

When a fixup absorbs into an earlier commit, all subsequent commits replay on top of the
changed state. A conflict means a later commit modified the same lines.

**The key insight**: don't resolve conflicts mechanically by choosing sides. A conflict
means "this later commit had a purpose — re-implement that purpose given the new context."

Example: feedback fixes a typo in `get_user()`. Then a later commit adds a lint rule and
reformats `get_user()`. After autosquash, the lint commit conflicts because the baseline
changed. Resolution: apply the lint rule to the new version of `get_user()` — don't just
accept either side blindly.

If the conflict's intent is unclear, stop and ask the user: explain which two commits are
conflicting, what each was trying to do, and ask how they should compose.

### Step F8: Verify

```bash
git log --oneline
git diff $MERGE_BASE..HEAD --stat
```

Stat must match the pre-feedback stat exactly. The feedback commits should no longer appear
as separate entries.

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

**Renamed files**: use the new filename in `commit-plan.json`. After `git reset --soft`,
the old file doesn't exist — only the new name is in the working tree.

**apply failure**: try `--ignore-whitespace --recount`. If still failing, use `git add -p`.

**Recovery**: original commits are in reflog:
```bash
git reset --hard HEAD@{1}
```
