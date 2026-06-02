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

If the tree is dirty, stop and tell the user to commit or stash first. The generated script
re-checks and refuses to run, but check up front to avoid wasted effort.

The script also refuses if the range contains **merge commits** (soft reset flattens them).
If `git rev-list --merges $MERGE_BASE..HEAD` is non-empty, this skill is the wrong tool.

## Step 1: Find the base

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

Write to a scratch dir **outside the repo** so artifacts never dirty the working tree:

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

This produces `$WORK/stage-and-commit.sh`. The script self-guards: checks tree is clean,
refuses on merge commits or detached HEAD, writes a durable backup ref under
`refs/tidy-backup/<ts>`, and auto-restores on any failure via an EXIT trap.

## Step 6: Execute

```bash
bash "$WORK/stage-and-commit.sh"
```

The script ends with a **tree-identity gate**: `git diff --quiet $TIDY_BACKUP HEAD`.
If the rewritten history doesn't reproduce the original tree byte-for-byte, it prints the
diff stat, hard-resets to the backup, and exits non-zero. Clean exit = content provably unchanged.

If apply fails, the script auto-restores. Retry with `--ignore-whitespace --recount`; if
still failing, see `ref/edge-cases.md`.

## Step 7: Verify

```bash
git log --oneline
git diff --quiet $TIDY_BACKUP HEAD && echo "tree identical" || echo "DRIFT — do not ship"
```

`$TIDY_BACKUP` is printed by the script and persists at `refs/tidy-backup/<ts>`. Clean up:
```bash
rm -rf "$WORK"
```

---

## Reference files (load on demand)

When you need a section below, find and Read it:
```bash
find ~/.claude/skills -path "*/git-tidy-branch/ref/<name>.md" | head -1
```

| Situation | File |
|-----------|------|
| Trailing "address feedback" / "nit" commits to absorb | `ref/pr-feedback.md` |
| Rebase branch onto updated upstream base | `ref/rebase-upstream.md` |
| Conflict during rebase or autosquash | `ref/conflict-resolution.md` |
| Renames, binary files, deleted files, lost backup | `ref/edge-cases.md` |
