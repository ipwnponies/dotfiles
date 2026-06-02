# Step 8: Rebase onto latest base (optional but recommended before PR)

After history is clean, check if the base branch has moved. Unlike the tidy steps, this
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
unexpected `<` (dropped) or content change beyond what the conflict resolution explains
means investigate.

**Do not rebase a dirty branch.** This step must come after Steps 1-7 (history cleaned up
first). Rebasing a messy branch creates two layers of complexity: conflict resolution AND
history reorganization simultaneously. Clean first, rebase second.

If conflicts arise, read `ref/conflict-resolution.md`. To bail out at any point:
```bash
git rebase --abort               # restores to REBASE_BACKUP
```
