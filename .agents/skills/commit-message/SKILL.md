---
name: commit-message
description: >
  Use whenever drafting a git commit message — after generating code changes, when the
  user says "commit", "commit this", or asks for a commit message. Keeps subjects
  Conventional-Commit-shaped and bodies at spec level (what changed, why) instead of
  narrating the diff.
---

# Commit Message

After generating code, if the working tree has enough changes for a coherent, complete
commit, suggest one to the user with a drafted message.

## Subject

Conventional Commit shape: `type: short description` (or `type(scope): short
description` in a multi-project repo — derive scope from recent history for the same
area, reuse the most common existing label). Under 80 characters. Pick a type (`feat`,
`fix`, `docs`, `refactor`, `chore`, ...) matching the change's intent.

State the net effect: a fact about what's different now, as either the fix/mechanism
itself (`anchor the report's date range to UTC instead of server-local time`) or the
symptom plus its cause (`fix off-by-one day in nightly report caused by local-time
date range`). Naming just the specific target affected (`fix nightly report date
range`) clears the bar too — weaker than naming the mechanism or the cause, but still
concrete, not a category label (`fix bug`), not a file name (`update report_job.py`),
not a vague quality claim (`improve reporting reliability`), and not diff narration
(naming the specific function/variable/call invented for the change, e.g.
`use datetime.utcnow() for...` — same rule as the body's self-check below, applied to
the subject).

State what the commit does, not the bug it observes. `nightly report emails wrong day
during DST` describes the broken state as a standing fact — a bug-ticket title, not a
commit subject — and never says what changed. Lead with the action even on a `fix`:
`avoid DST-caused day shift in nightly report`.

Mechanical check: the subject must complete "If applied, this commit will
\_\_\_." `anchor date range to UTC` → "If applied, this commit will anchor date range
to UTC" ✓. `nightly report emails wrong day during DST` → "If applied, this commit
will nightly report emails wrong day during DST" ✗ — doesn't parse, which is the tell
it's an observation, not an action.

If stating the net effect needs a trailing "so that..." justification clause to land,
that justification is the body's job, not the subject's — cut it and let the body
carry it.

The limit is a smell detector, not a target to hit by any means necessary. If the
natural, plainly-worded summary doesn't fit, that's a signal about the commit, not
about the wording:
- The commit is doing too many things → split it into separate commits.
- The summary is carrying detail that belongs in the body → move it there and
  re-summarize the subject at a higher level.

Never force a fit by inventing shorthand, symbols (`+`, `/`, `&`), or abbreviations
that don't already exist in the codebase's own vocabulary. A subject that's a couple
characters over is fine; reach for split-or-defer instead of compression tricks.

## Body — spec level, not diff narration

Write at the level of a single logical change's spec: what capability or behavior is
now different, and why it was needed. It's fine to be specific — name the exact
function, behavior, or edge case this commit addresses — but never restate the diff
as prose ("renamed X to Y", "added an if-check for Z"). If the subject line already
says it, the body doesn't need to repeat it.

1-3 sentences is the target; more is the exception. Omit the body entirely when the
subject is self-explanatory (e.g. a one-line config/gitignore change).

## Example

```
refactor: move pet state systems into modules

Growing state logic embedded in app.js made pet behavior hard to
test and reuse in isolation.
```

## Self-check

Read the body back. If a sentence just paraphrases a line of the diff — mentions a
variable/function name invented for this change, or describes control flow — cut it.
That's implementation narration, not spec.
