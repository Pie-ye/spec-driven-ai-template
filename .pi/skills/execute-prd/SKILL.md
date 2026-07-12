---
name: execute-prd
description: Execute one Trellis PRD with strict scope control, checkpoint commits, and verification.
---

# Mission

Implement exactly one active canonical PRD from `.trellis/prds/<PRD-ID>-<slug>.md`.

# Required reading

Read root and affected module/profile `AGENTS.md`, `PRD_EXECUTION.md`, the complete PRD, relevant `.trellis/specs/`, research, and ADRs before editing.

# Workflow

1. Restate the goal, acceptance criteria, and non-goals.
2. Inspect affected files and existing tests.
3. Report intended file scope.
4. Make the smallest coherent change.
5. Run targeted checks and create focused checkpoint commits.
6. Run `mise run doctor`, `mise run setup`, and `mise run verify`.
7. Review the final diff and map every criterion to evidence.

# Rules

One branch implements one PRD. Do not merge automatically, hide failures, or touch unrelated files. Use `.template/profiles.toml` rather than guessing capabilities. Prefer native build systems over generic preferences.

# Output

Report task, branch, scope, AC-1..N status with evidence, changed files, commands, risks, and `READY_FOR_REVIEW` or `CHANGES_REQUIRED`.
