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

If the count is 0, the branch's content is already current relative to base — skip the tree
rebase itself. Still run the identity check below: commits this run never touched (branch
taken over from elsewhere) may predate this session and carry a different committer.

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

## Verify commit identity (Claude Code Remote)

Run regardless of whether the count above was 0 or the tree rebase ran. Claude Code Remote
environments run a Stop hook that blocks every turn on any commit with a missing signature or
a committer email that doesn't match the environment's configured identity. Rebase only
restamps commits it actually replays — a no-op (count 0) or a rebase that fast-forwards
without replaying leaves existing commits, and their original committer, untouched.

Skip entirely when not in a Claude Code Remote environment (`commit.gpgsign` unset or false,
no stop hook present) — nothing to normalize against.

```bash
EXPECTED_EMAIL=$(git config user.email)
git log --format='%h %G? %ce %s' "$REMOTE/$BASE..HEAD"
```

Split findings into two cases against `$EXPECTED_EMAIL` — they need different handling:

- **Committer already matches `$EXPECTED_EMAIL`, only `%G?`==`N`.** This environment has no
  `gpg.ssh.allowedSignersFile` configured, so even a commit Claude genuinely signed this
  session reports `N` locally (not a real signal). Re-sign silently, no user input needed:
  ```bash
  git rebase --exec "git commit --amend --no-edit --reset-author" "$REMOTE/$BASE"
  ```

- **Committer does NOT match `$EXPECTED_EMAIL`.** Real signal — commit(s) Claude didn't create
  this session. **Stop and ask the user before rewriting anything.** Show the flagged commits
  (`%h %ce %s`) and confirm it's OK to reclaim them under the current identity (rewrite
  committer, re-sign, changes their SHA) before running the same `reset-author` rebase. If
  declined, leave as-is and note the Stop hook will keep blocking on push until resolved
  manually.
