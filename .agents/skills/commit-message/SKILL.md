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

State the nature of the change precisely: either the approach/mechanism used, or a
specific, quantified characterization of its effect (a complexity class, a concrete
before/after number, a named behavior change). A vague capability claim ("speeds up
lookups", "improves performance") isn't precise — it could mean anything from a minor
tweak to a rewrite. Naming the literal algorithm or data structure isn't required once
the outcome is already stated precisely (`lookup cost now scales logarithmically
instead of linearly`) — the reader can find the exact mechanism in the diff; restating
it doesn't change the reason for the change.

The subject is mandatory and can already carry the why (per the subject rules above);
the body is optional and purely additive. Restating a why the subject already gave
isn't wrong, just usually unnecessary — add it explicitly when the subject didn't have
room for it, or the approach alone wouldn't make the motivation clear.

Never restate the diff as prose (naming a variable/function/library call invented for
this change, or describing control flow) — that's implementation narration, not spec;
the reader can read the diff for that. Naming an existing, already-established symbol
is fine. Describing real shipped behavior that's part of the design (a fallback
threshold, a documented limit) is fine too — the line is defending the choice against
alternatives you didn't take, or cataloging edge cases/tests, not describing what
actually ships.

Use as many sentences as the change needs to state precisely. More than 3 is a smell,
not a hard cap: either the commit is doing too much (split it) or the sentences are
overlapping/restating each other (cut back to whichever ones carry distinct
information). Wrap body lines at 100 characters. Omit the body entirely when the
subject is self-explanatory (e.g. a one-line config/gitignore change).

## Layout — separate related points and distinct themes

Within a commit's theme, you may state several related points (the problem, the
approach, the consequence, an edge case).

- **Multiple complete sentences on distinct points** → newline between them
- **Dependent qualifier/continuation within a sentence** → use punctuation (semicolon,
  em-dash) not line break
- **Distinct themes/topics** → blank line separation for clarity

Avoid run-on sentences that merge multiple points into one hard-to-parse statement.
Avoid blank lines when points relate to the same change — they signal separate themes.

Example (three related points, each its own sentence):
```
Organize weighted choices into named, collapsible groups instead of a flat list.
Single-expand accordion behavior keeps one group open at a time, with results resetting when switching.
Existing localStorage data migrates automatically into a single "Default" group.
```

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
