---
name: commit
description: Conversation-scoped commit workflow that stages only files discussed/edited in the current request.
---

# Commit Orchestration

## Purpose

- Keep commits constrained to the files explicitly touched during this conversation, avoiding unrelated old dirty work.
- Provide a structured `STAGE_MANIFEST` built from conversation context so the committer stages exactly those files and leaves every other dirty file untouched.

## Trigger examples

- "Please commit the logging refactor we just discussed."
- "Stage the files we edited here and run the commit flow."
- "Everything we changed in this conversation should be committed together; use my latest intent for the message."

## Intake rules

- Use `$ARGUMENTS` as the user’s commit intent/message candidate. Feed it through the `committer` classifier contract (final vs intent).
- When the user does not provide an explicit message, summarize the request and the relevant files from the conversation context when you invoke `/commit`.
- Do not infer new files from `git status`; build the scope only from files already mentioned/edited in this conversation (either by the user or by the assistant while editing).

## Scope construction from conversation

1. Identify the list of files you touched for this request by reviewing the conversation transcript: track every edit you performed and every user confirmation that a file should be part of this change.
   - For example, if you issued `Edit` on `src/cache/impl.rs` earlier in this conversation, that file belongs to the manifest.
   - If the user explicitly said "also include `doc/spec.md`" or similar, add that file too, but only after confirming its contents as part of the same conversation.
2. Verify each candidate file still has modifications by running `git diff -- <path>` or `git status --short <path>`; if a file no longer has edits, drop it and document the exclusion in the context packet.
3. Build `STAGE_MANIFEST.include` from the deduplicated list of confirmed conversation-scoped files.  
4. Build `STAGE_MANIFEST.exclude` from the remaining dirty files reported by `git status --short`, so the committer knows to leave them unstaged.  
5. Treat `STAGE_MANIFEST` as a file-path boundary, not permission to guess partial scope: if an included file is partially staged, the committer must preserve those staged hunks as the explicit scope contract.
6. Once the scope is explicit, the committer may temporarily stash unrelated unstaged work with `git stash push --keep-index --include-untracked` before committing, then restore it with `git stash pop` after the commit completes.

If you cannot assemble this manifest because the conversation did not yet cover the affected files (for example, the user asked "commit everything" without specifying files), return `NEEDS_USER_INPUT` (`kind: scope_change`) asking the user to list the files or confirm that the list you inferred should be committed.

## Context packet contract

- `Recent conversation context:` summarize the latest exchanges that led to the commit request, including bug refs or QA notes.
- `Current user intent:` restate what the user wants the commit to accomplish (e.g., "commit the cache feature fix they reviewed this turn").
- `Files in scope:` list each manifest file with a brief note about why it must be included ("updated for the cache refactor", "puts the new helper behind the feature flag").
- `Constraints and approvals:` mention any special instructions, such as skipping tests, stacking multiple slices, or waiting for approval before pushing.
- `Open questions and risks:` surface anything unresolved (for example, "file `proto/state.proto` is still mid-review; commit only the other files").

If the user later wants to add an externally edited file not yet discussed, perform a short review of that change within the conversation, confirm its inclusion, and only then append it to the manifest list before dispatching `/commit`.

## Dispatch

- Call `/commit` with the assembled context packet plus the `STAGE_MANIFEST` block so the committer stages only the approved files. Ensure the prompt includes both the intent message (or summary) and the manifest.
- After the commit, remind the user to mention any future additional files explicitly so the scope stays this clean.
