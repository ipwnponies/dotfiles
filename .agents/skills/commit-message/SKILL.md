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
area, reuse the most common existing label). Under 70 characters. Pick a type (`feat`,
`fix`, `docs`, `refactor`, `chore`, ...) matching the change's intent.

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
