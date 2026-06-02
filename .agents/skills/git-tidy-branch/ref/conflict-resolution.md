# Intelligent conflict resolution

When `git rebase` or `git rebase --autosquash` stops on a conflict, do NOT blindly choose
"ours" or "theirs". Instead, understand both intents and re-implement them together.

## The protocol

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
