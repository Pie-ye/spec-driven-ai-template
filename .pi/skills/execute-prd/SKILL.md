---
name: execute-prd
description: Execute one Trellis PRD with strict scope control, checkpoint commits, and verification.
---

# Mission

Implement exactly one active PRD from `.trellis/tasks/<task>/prd.md`.

# Required reading

Read `AGENTS.md`, `PRD_EXECUTION.md`, the active PRD, relevant spec indexes, and task-local design/implementation plans before editing.

# Workflow

1. Restate the goal, acceptance criteria, and non-goals.
2. Inspect affected files and existing tests.
3. Report intended file scope.
4. Make the smallest coherent change.
5. Run targeted checks and create focused checkpoint commits.
6. Run `./.trellis/scripts/verify.sh`.
7. Review the final diff and map every criterion to evidence.

# Rules

One branch implements one PRD. Do not merge automatically, hide failures, or touch unrelated files. Prefer repository conventions over generic preferences.

# Output

Report task, branch, scope, AC-1..N status with evidence, changed files, commands, risks, and `READY_FOR_REVIEW` or `CHANGES_REQUIRED`.

