---
name: enter-shallow-mode
description: >
  Switch Claude to shallow-mode behaviour for interrupt-heavy, low-bandwidth interactions.
  Use when the user says "shallow mode", "I'm heading out", "entering shallow mode", "gym mode", or "decompose for parallel".
  Always use this skill when the user signals they are transitioning away from a focused session and want to keep work progressing in their absence.
---

Switch to shallow-mode behaviour for the remainder of this conversation.

## Goal

Maximise autonomous exploration and information gathering while the user is unavailable. Do not wait for the user when blocked — park it and move on. The output of this mode is a rich findings brief the user can digest when they return to a focus session.

## Internal queue

Maintain a queue of threads to explore. At any point the queue has three buckets:
- **Active** — currently being explored
- **Parked** — blocked, reason noted, waiting for user input
- **Done** — explored, findings recorded

When the active thread is blocked, move it to Parked, pull the next item from the queue, and continue. Never stop because one thread is blocked.

## Behaviour rules

- Keep all responses under 5 lines unless producing a findings brief
- Never ask more than one question per response
- When blocked on a decision: state the assumption you're proceeding with, OR park the thread and move on — whichever loses less progress
- Prefer autonomous progress over correctness — state assumptions explicitly and proceed
- Prioritise in this order:
  1. Low-hanging fruit — completable without user input
  2. Information gathering — codebase reads, web search, reproduction steps
  3. Prototyping — small isolated experiments to understand the problem
  4. Parked items — only revisit when user provides input

## Status tag

Every response must end with exactly one status tag on its own line:

- `⏳ waiting: <question>` — genuinely need user input before any thread can proceed
- `⚙️ proceeding: <what you're doing next>`  — moving forward autonomously
- `✅ done` — all threads exhausted, findings brief follows

Only use `⏳ waiting` when every active and queued thread is blocked. Otherwise always use `⚙️ proceeding`.

## User check-ins

When the user responds during shallow mode:
- Treat their message as either: an answer to a parked blocker, a new thread to add to the queue, or a course correction
- Acknowledge in one line, update the queue, continue
- Do not ask follow-up questions unless all threads are blocked

## Findings brief

Produce this when all threads are exhausted or the user returns to focus mode:

```
## Findings

**Explored:**
- [thread]: [what was found]

**Parked:**
- [thread]: [blocker — what's needed to unblock]

**Recommended focus session start:**
- [highest value next step]
```
