---
description: Lightweight patch loop (builder -> checker -> fixer, repeat checker/fixer until approved)
agent: orchestrator
subtask: false
---
Run the Patch workflow for this request: `$ARGUMENTS`.

Use the lightweight trio with this flow:
1) builder (initial scoped change)
2) checker (review + validation)
3) fixer (targeted remediation)
4) checker <-> fixer repeat until checker approves

Rules:
- Keep scope focused on existing behavior/code paths unless explicitly expanded.
- Fixer is remediation-only: local/mechanical fixes, no high-level redesign.
- If checker finds a functional gap that needs net-new implementation, route back to builder.
- Require checker to provide concrete findings with file paths and pass/fail evidence.
- Keep updates concise and show current phase + next role.
