---
description: Full-team delivery flow (orchestrator -> researcher -> implementer -> reviewer -> qa)
agent: orchestrator
subtask: false
---
Run the Design-Build workflow for this request: `$ARGUMENTS`.

Use the full team in this order:
1) researcher
2) implementer
3) reviewer
4) qa

Rules:
- Keep handoffs explicit and use the required ROLE/STATUS/DONE/NEXT/BLOCKERS/ARTIFACTS format.
- If reviewer requests changes, route back to implementer.
- If QA fails, route back to implementer.
- Close only when reviewer approves and QA provides explicit pass evidence.
- Keep updates concise and show current phase + next role.
