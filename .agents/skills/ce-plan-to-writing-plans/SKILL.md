---
name: ce-plan-to-writing-plans
description: Use after ce-plan has produced a plan artifact (docs/plans/*.md), to hand it to superpowers:writing-plans as the spec without redoing ce-plan's research, decisions, or atomic-unit breakdown. Typically invoked right after a ce-plan session ends (at or after its post-plan menu), when the user says something like "now write the plan", "write it out", "flesh this out", "detail it out", "move on to write plan", or "make it executable" — as opposed to a fresh, from-scratch "write a plan" request with no prior ce-plan artifact.
---

# CE-Plan → Writing-Plans Bridge

## Overview

`ce-plan` produces a plan document with decisions, scope, atomic units (U-IDs),
files, and test scenarios already researched and settled — but deliberately
contains no code, no exact signatures, and no step-by-step choreography.

`superpowers:writing-plans` produces the opposite: checkbox tasks with
complete code per step, ready for `subagent-driven-development` to execute.

This skill bridges the two without wasting tokens re-deriving what `ce-plan`
already worked out.

**Announce at start:** "I'm using the ce-plan-to-writing-plans bridge skill
to hand this plan off for implementation detailing."

## Trigger disambiguation

"Write the plan" / "write it out" / "flesh this out" is ambiguous on its
own — it could mean start `writing-plans` from scratch, or it could mean
this bridge. Disambiguate by recency, not phrasing alone:

- **A `ce-plan` artifact was just produced earlier in this same
  conversation** (its post-plan menu fired, or the user stopped before
  picking a menu option): use this skill. The path is already known from
  context — do not re-ask for it.
- **No `ce-plan` artifact in the current conversation**: this is a
  from-scratch request. Don't assume one exists — invoke `writing-plans`
  directly, or ask the user, instead of guessing this skill applies.

## Input

Requires the path to a `ce-plan` output file, e.g.
`docs/plans/2026-08-04-001-feature-name-plan.md`.

If the path isn't recoverable from the current conversation, ask for it.
Do not guess or search for "the most recent plan" on disk — confirm the
exact file.

## Steps

1. Read the `ce-plan` file. Confirm `artifact_readiness: implementation-ready`
   (not `requirements-only`). If it's `requirements-only`, stop and tell the
   user `ce-plan` hasn't finished enriching it yet — don't proceed on a
   partial plan.

2. Invoke `superpowers:writing-plans` using this file as the spec, with the
   following instructions prepended to the handoff:

   ```
   Use writing-plans on <path> as the spec.

   The scope, decisions, atomic units (U-IDs), and test scenarios in this
   document are already finalized — don't re-research or re-derive them.
   Treat each atomic unit as one task (split further only if a unit needs
   more than one commit). Use the test scenarios already listed per unit
   as your TDD test cases instead of inventing new ones. Your job is to
   add what this document deliberately left out: exact file paths,
   complete code per step, and commands with expected output.

   Exception: if writing actual code reveals that a decision in this
   document doesn't hold up against the real codebase, don't force-fit
   it. Note the deviation inline in the plan and proceed with the
   correct approach — same as you would if a spec turned out to be
   wrong once you started building.
   ```

3. Let `writing-plans` run its normal process (file structure, task
   breakdown, self-review, execution handoff). No changes to its own
   behavior beyond the input framing above.

## What this skill does NOT do

- Does not decide whether to run `ce-plan` in the first place — that's a
  manual call, invoke `ce-plan` yourself first if the task warrants it.
- Does not hand off to `subagent-driven-development` — `writing-plans`
  already does that itself via its own Execution Handoff step.
- Does not touch `ce-plan`'s post-plan menu (issue creation, Proof, browser)
  — those are CE's own next steps; this skill is what you run instead of
  picking from that menu.
