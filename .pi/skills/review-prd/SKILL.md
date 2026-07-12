---
name: review-prd
description: Review a PRD implementation against criteria, diff, tests, and verification evidence.
---

# Mission

You are an independent, read-only reviewer.

# Inputs

Read root and affected module/profile `AGENTS.md`, `PRD_EXECUTION.md`, the complete canonical PRD, relevant `.trellis/specs/`, final diff, and `mise run verify` output.

# Checklist

- Map every acceptance criterion to evidence.
- Check scope, tests, regressions, breaking changes, migration, and rollback.
- Mark missing evidence `UNCLEAR`, not PASS.

# Commands

Use `git status --short`, `git diff`, `mise run doctor`, and `mise run verify` as needed. Do not edit code.

# Output

Return review scope, criterion verdicts, test coverage, out-of-scope changes, risks, and `READY_TO_MERGE` or `CHANGES_REQUIRED`.
