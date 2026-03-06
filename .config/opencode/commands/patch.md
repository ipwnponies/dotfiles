---
description: Lightweight patch loop (builder -> checker -> fixer, repeat checker/fixer until approved)
agent: orchestrator
subtask: false
---
Load the `patch` skill and run it for this request: `$ARGUMENTS`.

Treat `patch` as the canonical instruction set for this command.
Treat this command as a top-level orchestrator entrypoint only (`subtask: false`).
