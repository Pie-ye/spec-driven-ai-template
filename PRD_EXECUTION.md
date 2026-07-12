# PRD_EXECUTION.md

## Source of truth

The active canonical PRD under `.trellis/prds/` defines scope, acceptance criteria, non-goals, constraints, dependencies, and evidence requirements. Product context belongs in `.trellis/specs/`; research is not a substitute for a decision or PRD.

## Lifecycle

`Draft → Ready → In Progress → Implemented → Verified → Reviewed → Merged → Archived`

Only one PRD is active on a branch. A new need discovered during implementation becomes a follow-up PRD unless it blocks the current acceptance criteria.

## Branching

Use `prd/PRD-001-slug`, `fix/PRD-001-slug`, or `refactor/PRD-001-slug`. Create a PRD branch from updated `main` with:

```bash
./scripts/create-prd-branch.sh PRD-001 slug
```

The helper requires a clean tree, uses fast-forward-only update, and never resets, deletes, force-pushes, or merges.

## Task contract

The root `mise.toml` exposes:

`doctor`, `setup`, `dev`, `format`, `format-check`, `lint`, `typecheck`, `test`, `build`, `verify`, and `clean`.

The root dispatcher executes only explicitly enabled profiles/modules from `.template/profiles.toml`. Profile-native tools remain authoritative.

## Execution gate

Before editing, the primary agent must read root/module `AGENTS.md`, the complete PRD, applicable specs, and referenced research. It must inspect the repository, list intended files, implement narrowly, add/update tests, and run targeted checks.

## Verification gate

Local and CI use the same commands:

```bash
mise run doctor
mise run setup
mise run verify
```

`verify` must label profile/module results and fail on a required task failure. Missing optional tasks may be skipped explicitly.

## Review and merge gate

The independent reviewer must map every acceptance criterion to evidence and report test gaps, regressions, out-of-scope changes, security concerns, maintainability, and documentation gaps. Merge requires all criteria Pass, verify/CI success, `READY_TO_MERGE`, and a cleanly mergeable branch. No script or agent merges `main` automatically.

## Finish helper

```bash
./scripts/finish-prd.sh PRD-001
```

It validates the branch, runs `mise run verify`, checks the evidence table, and writes a review summary. It stops before merge.
