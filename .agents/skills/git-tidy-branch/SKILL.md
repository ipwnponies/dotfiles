---
name: git-tidy-branch
description: >
  Reorganizes messy git commits on a branch into logical, atomic, reviewer-friendly commits.
  Use this skill when the user wants to clean up their branch before code review, says things
  like "tidy my commits", "clean up branch history", "prep for PR", "reorder commits",
  "atomic commits", "my commits are a mess", "squash and reorganize", "reviewers will hate
  my git log", "absorb PR feedback into commits", "squash feedback into history", "clean up
  after review", "incorporate review changes", or "this is a new/unmerged feature, why does
  it have fix commits". Handles all starting states: one giant commit, dozens of WIP commits,
  wrong-order commits, or clean-looking history that still has self-fix commits anywhere in
  the range — trailing or interleaved, in code or in docs/config — that need absorbing back
  into whichever earlier commit they correct. Produces a history where each commit is
  coherent in isolation and tells a clear story. Operates autonomously.
---

Reorganize messy branch history into clean, atomic, reviewer-friendly commits. Operate
autonomously: analyze → decide → execute. Only pause for user input when you've exhausted
options and guessing wrong would be worse than asking.

The story to tell a reviewer: first why (refactor/setup), then the test, then the change,
then cleanup.

**Governing rule — no self-fix commits survive, of any kind.** If a commit's real job is to
fix, correct, revise, close a gap in, or otherwise change something an *earlier commit in
this same range* introduced, it does not get to exist as its own commit in the final
history — fold it into the commit it corrects. This holds regardless of:
- **File type.** A `docs:` commit revising a plan/spec/README that an earlier commit in the
  range added is the identical pattern to a `fix:` commit correcting code — a reviewer of an
  unmerged branch doesn't want to watch a document (or a config file, or a test) get revised
  in front of them any more than they want to watch code get revised. Fold it.
- **Position.** "Trailing" is the common case (review found issues at the end of a session)
  but not the only one — a self-fix can land anywhere in the range, including immediately
  after the commit it corrects, or between unrelated commits. Scan the *whole* range, not
  just the tail.
- **How the commit is labeled.** A commit doesn't have to say `fix:` to be a self-fix. A
  `feat:` or `docs:` commit whose diff only makes sense as "revise/complete what commit X
  already introduced" is a self-fix under a different conventional-commit type. Judge by
  what the diff does to earlier content in the range, not by the type prefix.

The only commits exempt from this rule are ones fixing something that predates the range
(a real bug in code the branch didn't introduce) — those are legitimate standalone `fix:`
commits and stay as-is.

This is not a special mode invoked only when the user asks for it — it is part of what
"tidy" means. Step 2 below runs this check unconditionally, on every branch, including ones
that otherwise look clean.

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

**First, unconditionally: scan for self-fix commits.** Before classifying anything else,
read every commit's message and diff (not just the tail) and ask of each one: does this
commit's real job start with "fix/correct/revise/close a gap in" something an *earlier
commit in this range* introduced — in any file, code or docs or config? A commit that
reads as its own self-contained capability, even a small one, is not a self-fix just
because it happens to touch a file an earlier commit also touched. Look for the signal
in the message itself first (a `fix:`/`chore:` commit whose target is inside the branch,
not upstream of it; a `docs:` commit whose body says "resolve", "close gaps", "address
review", "correct"), then confirm from the diff. If any exist — anywhere in the range,
however well-labeled and however clean the rest of the branch looks — this branch is
**not** clean regardless of what the rest of this classification says, and needs the
fold described in `ref/pr-feedback.md` before (or as part of) whatever else this pass
does. That reference file's mechanics work the same whether the self-fix is at the tail
or in the middle of the range, and whether the files involved are code or not — don't
let its "trailing" framing or code-focused examples read as a scope limit.

Then classify the rest silently:
- **Single commit**: needs splitting
- **WIP mess**: many small commits to be regrouped
- **Wrong order**: commits exist but sequence is wrong
- **Mixed**: combination
- **Already clean**: hunks are already atomic and correctly ordered, no self-fix commits
  found, no regrouping needed. Still continue to Step 3.5 — clean grouping says
  nothing about whether the *messages* meet convention, especially on a
  branch built by another tool or session (subagent-driven development,
  an earlier assistant run, a rebase import). Do not shortcut past message
  validation just because there's nothing to regroup.

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

## Step 3.5: Validate and draft commit messages

**Runs for every classification, including Already clean.** A commit's hunks needing
no regrouping doesn't mean its message is convention-compliant — squashing or
splitting always invalidates the old message (it described a different diff), and
even an untouched 1:1-mapped commit may predate this pass or come from a different
process (SDD, another assistant session, an imported branch) that didn't apply these
conventions.

For every commit the plan will produce — new groups AND existing commits kept as-is —
invoke the `commit-message` skill and check the message against its rules before
accepting it:
- Subject: Conventional Commit shape, **≤80 chars** (a couple chars over is fine; past
  that, split the commit or defer detail to the body rather than compress the wording)
- Body: spec-level (what changed, why) — not diff narration, not a list of internal
  function/variable names invented for the change (apply the skill's own self-check:
  if a sentence just paraphrases a diff line or names an invented identifier, cut it)
- Body length: more than 3 sentences is a smell, not a hard cap — a commit bundling
  several distinct findings can justify it, but check it's earning the length rather
  than defaulting to it
- Omit the body only when the subject is genuinely self-explanatory

Any commit that fails gets a rewritten message, whether or not its hunks move. This
is what makes the rewritten history read as if it had been committed with intent the
first time, not just reshuffled hunks (or preserved-but-uninspected hunks) with
whatever label they happened to arrive with.

**If every commit needs regrouping anyway** (WIP mess / Wrong order / Mixed / Single
commit): fold the validated messages into the commit plan below — Steps 4-6 already
rebuild history from scratch, so message correctness is free to fix at the same time.

**If the branch is Already clean and hunks don't need to move, but one or more
messages fail validation**: don't force it through the hunk-extraction machinery
(Steps 4-6) just to change text — that risks the full-range diff hunking differently
than each commit's own diff did, corrupting boundaries between commits that didn't
need to change. Instead rewrite messages only, preserving trees exactly:

```bash
git update-ref refs/tidy-backup/$(date +%s) HEAD   # backup ref first, same as the script
TIDY_BACKUP=refs/tidy-backup/<ts>                   # the ref just created

parent=$MERGE_BASE
for sha in $(git log --format=%H $MERGE_BASE..HEAD --reverse); do
  tree=$(git rev-parse "$sha^{tree}")
  # Use the original message unless this commit failed validation above,
  # in which case substitute the rewritten one.
  parent=$(git commit-tree "$tree" -p "$parent" -m "$MESSAGE")
done
git update-ref refs/heads/$(git symbolic-ref --short HEAD) "$parent"
```

Because each new commit reuses the *original* tree object verbatim, tree identity is
guaranteed by construction, not just by a passing diff — there's no risk of the
rewrite accidentally changing content. Still run the Step 7 verify as a check.

## Step 3.6: Watch for declare-before-consume ordering across the fold

Folding a self-fix (or any hunk-split) into an earlier commit can hit a real dependency
problem: a hunk needed in the earlier commit references a declaration (a state variable,
a ref, an import, a helper) that, in the original diff, was only added by a *later*
commit — because the fix touches code that both commits share. You cannot put the
consuming hunk in the earlier commit while its declaration stays in the later one; that
earlier commit won't build.

Resolve it in this order:
1. **Move the declaration itself earlier**, into whichever commit is now first to need
   it. This is almost always safe and is the default move — a `const`/`useState`/import
   sitting one commit before its first *use* is normal, not a smell.
2. If step 1 leaves the earlier commit with something declared but not yet consumed
   (e.g. a state getter whose only reader is a later commit's JSX), that is an accepted,
   expected artifact of the split — not a reason to force the hunks back together. It
   will surface as a lint finding in Step 6.5; that step's guidance on judging it applies.
3. Only if neither resolves cleanly (the dependency is genuinely circular, or splitting
   would require inventing code that doesn't exist in the original diff to make an
   interior commit self-consistent): stop splitting that pair and keep the hunk in its
   own commit instead, even if that means one more commit than the ideal grouping. A
   slightly less-collapsed history beats a fabricated intermediate state.

This is a normal, expected part of folding — not a sign the fold was a bad idea. Don't
let hitting it talk you out of the Governing rule at the top of this file.

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
      "message": "fix: reject expired tokens on refresh endpoint\n\nRefresh silently re-issued tokens past their expiry, letting revoked\nsessions keep working indefinitely.",
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
- `message` goes straight to `git commit -m` — first line is the subject, a blank line plus
  following lines become the body. Use the messages drafted in Step 3.5.
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

## Step 6.5: Verify each resulting commit in isolation, not just the tip

Tree-identity proves nothing was lost or duplicated across the whole rewrite. It does
**not** prove each individual commit is independently valid — a fold or hunk-split can
produce an interior commit that fails to build, lint, or run its own tests even though the
final tip is perfect (a later commit consumed a declaration this one only partially added,
a hunk pulled in a reference to something the next commit defines, etc.). This bites
hardest exactly when Step 3.6 (below) had to be used, since that's where a hunk was
deliberately reordered ahead of a dependency it doesn't fully resolve until a later commit.

For every commit the plan produced (not just HEAD), check it out into a disposable
worktree and run the project's real verification commands — build, lint, and the test
subset covering the touched files:

```bash
for sha in <each new commit, oldest to newest>; do
  git worktree add -q --detach .worktrees/check-$sha "$sha"
  ( cd .worktrees/check-$sha && <project's real lint command> && <project's real test command> )
  git worktree remove -f .worktrees/check-$sha
done
```

Use `.worktrees/` (repo-local) per the standing worktree convention, not an external
temp dir.

**Gotcha:** if `.worktrees/` (or wherever you put the check-out) is itself listed in
`.gitignore`, gitignore-aware tools — most linters by default — silently skip every file
under it and report a false "no issues" instead of actually checking anything. Pass the
tool's ignore-bypass flag (e.g. ESLint's `--no-ignore`) or check out somewhere not
gitignored. A clean run that skipped every file is not a clean run.

A real failure here is a finding, not necessarily a blocker — an interior-commit-only
lint gap (like a value declared one commit before its consumer starts reading it) is
often an accepted, expected cost of the split and self-resolves in the very next commit.
Surface it and let the user decide, per the same judgment call as Step 3.6's dependency
problem — don't silently ship it, and don't silently over-engineer around it either.

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
| Self-fix commits to absorb (trailing or scattered; code or docs/config) | `ref/pr-feedback.md` |
| Rebase branch onto updated upstream base | `ref/rebase-upstream.md` |
| Conflict during rebase or autosquash | `ref/conflict-resolution.md` |
| Renames, binary files, deleted files, lost backup | `ref/edge-cases.md` |
