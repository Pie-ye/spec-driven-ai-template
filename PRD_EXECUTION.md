# PRD_EXECUTION.md

## Goal

This file defines the execution rules for every PRD in this repository. The active PRD is authoritative for scope, acceptance criteria, non-goals, constraints, and verification requirements.

## Lifecycle

`draft → ready → in_progress → implemented → verified → reviewed → merged → archived`

`task.json` should use one of these states. A PRD is `ready` only when it has background, goal, scope, non-goals, acceptance criteria, constraints, dependencies, and verification notes.

## Branching

One PRD maps to one branch. Use names such as:

- `prd/PRD-042-session-expiry`
- `fix/PRD-043-refresh-race`
- `refactor/PRD-044-auth-boundary`

## Commit policy

Use focused checkpoint commits, for example `test(PRD-042): add coverage`, `feat(PRD-042): implement core change`, and `fix(PRD-042): address edge case`.

## Verification

The default command is `./.trellis/scripts/verify.sh`. It delegates to commands exposed by the application repository when their manifest exists.

## Review and merge gate

The reviewer must map every acceptance criterion to evidence, identify out-of-scope changes and regression risks, and give an explicit verdict. Do not merge until the PRD is reviewed, verification passes, the working tree is clean, the final diff is scoped, and required CI checks pass.

## Spec distillation

If implementation produces a reusable engineering rule, update the relevant file below `.trellis/spec/` before archiving the task.

