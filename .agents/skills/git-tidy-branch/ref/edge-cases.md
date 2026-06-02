# Edge cases, commit messages, and recovery

## Commit message guide

```
type(scope): imperative summary     ← ≤72 chars, no trailing period
```

**Types**: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `build`, `ci`, `perf`

## Edge cases

**Binary files / large assets**: whole-file only, no hunk splitting.

**Deleted files**: whole-file staging (`git add -- <path>` stages deletions too).

**Renamed files**: use the new filename in `commit-plan.json`. The script also stages the
old path so its deletion is recorded (otherwise the old file lingers and the tree diverges).

**apply failure**: try `--ignore-whitespace --recount` on the patch file in `$WORK/patches/`.
If still failing, stage the file manually:
```bash
git add -p <file>   # select the right hunks interactively
```
The script auto-restores on failure so you are back at the original tip; edit the plan and
retry from Step 4.

Only ask the user for help if both approaches fail and you can't determine which hunks
belong where without their domain knowledge.

## Recovery

The staging script prints `$TIDY_BACKUP` and writes a durable ref. Use that —
**not** `HEAD@{1}`, which after a multi-commit rewrite points at an intermediate commit.

```bash
git reset --hard $TIDY_BACKUP          # exact SHA the script printed
# or, if the shell variable is gone:
git for-each-ref refs/tidy-backup      # list backups; pick the right timestamp
git reset --hard refs/tidy-backup/<ts>
```

Backups under `refs/tidy-backup/` persist until you delete them; prune with:
```bash
git for-each-ref --format='%(refname)' refs/tidy-backup | xargs -n1 git update-ref -d
```
Run this after the branch is pushed and reviewed.
