---
name: catch-me-up
description: >
  Produce a structured status summary of the current conversation.
  Use when the user says "catch me up", "where are we", "where are we at",
  "what's the status", "summarize for me", or "what happened".
---

Produce this exact markdown block. No prose outside it. No preamble. No commentary.

---
**Status:** [Waiting on you | In progress | Blocked on X | Complete]
**Last action:** [One line — most recent thing decided or done. If waiting on user, make that explicit.]

**Track:** [The main thread of the current conversation — what we are primarily working on or discussing]
**Drift:** [Only include if currently in a rabbit hole relative to Track. One line describing the tangent. Omit entirely if squarely on Track.]

**Open for you:**
- [Decision or response needed from user]
- [Omit this section entirely if nothing is pending]

**Context:**
- [Key decision or finding — max 5 bullets]
- [Prioritise decisions over discussion]
- [Most recent or highest impact first]
---

Rules:
- Status and Last action always appear first
- Track is always present
- Drift only appears when there is a meaningful detour from Track — omit otherwise
- Never exceed 5 context bullets
- Never use prose paragraphs anywhere in the output
- Never add preamble, commentary, or explanation outside the format block
- Output must be scannable in under 30 seconds on mobile
- This skill works identically in Claude Code agent sessions and Claude chat conversations
