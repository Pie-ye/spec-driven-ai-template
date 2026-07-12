---
name: vibecoding
description: Start and coordinate a local natural-language VibeCoding session using Trellis, Pi subagents, Profile tasks, durable approvals, and evidence.
---

# Mission

Turn the user's natural-language request into a repository-grounded Spec/PRD proposal and, after approval, coordinate design, implementation, debugging, testing, review, and Draft PR delivery.

This workflow runs entirely inside the user's current local clone. Session state, worktrees, logs, and artifacts must remain inside that clone. GitHub PR/CI is only the final delivery boundary.

# Start a session

Before editing:

1. Read root and affected module `AGENTS.md`.
2. Read `.trellis/specs/`, active PRDs, relevant research, and ADRs.
3. Inspect `.template/profiles.toml`, branch, status, and current local repository.
4. Start or resume durable state with:

```bash
node scripts/orchestrator.mjs init PRD-XXX <session-id> <branch>
```

The state and JSONL events live under `.trellis/runs/PRD-XXX/<session-id>/` and remain local to this clone.

# Natural-language flow

1. Classify the request as feature, bug, refactor, migration, test, docs, or a combination.
2. Dispatch read-only `repository-explorer` and `spec-analyst` subagents in parallel.
3. Produce a Spec/PRD proposal with scope, non-goals, risks, tests, rollback, and evidence rows.
4. Request the `prd_scope` gate. Do not write implementation code until the user approves.
5. Create the PRD branch from local `main` using the repository branch policy.
6. Dispatch `architect`, `test-designer`, and `security-reviewer` in parallel.
7. Acquire the writer lock before the single `implementer` edits the primary working tree:

```bash
node scripts/orchestrator.mjs lock acquire PRD-XXX <session-id> <owner>
```

8. Run independent read-only exploration and analysis in parallel. Parallel writers must use separate local worktrees and return patches for integration.
9. Execute only `mise run` tasks and declared Profile/module adapters. Never invent language-specific commands from the model.
10. On failure, preserve output with `record-tool`, dispatch `debugger` diagnostics, add regression coverage, and respect the retry budget.
11. Run `mise run doctor`, `mise run setup`, and `mise run verify`.
12. Dispatch read-only `reviewer`, `security-reviewer`, and `documentation-writer`; map every criterion to evidence.
13. Request final diff approval, then create a Draft PR locally through the approved GitHub delivery tool. Never merge or deploy automatically.

# Approval policy

Pi may automatically perform repository reads, planning, tests, diagnostics, and approved sandbox commands. Pause for:

- Spec/PRD scope and acceptance criteria;
- destructive, irreversible, migration, secret-boundary, or newly external commands;
- final diff/evidence;
- merge or deployment.

Record every request and decision:

```bash
node scripts/orchestrator.mjs gate request PRD-XXX <session-id> prd_scope
node scripts/orchestrator.mjs gate approve PRD-XXX <session-id> prd_scope "user approved"
```

# Resume and report

After interruption, resume from state instead of reconstructing from chat:

```bash
node scripts/orchestrator.mjs resume PRD-XXX <session-id>
node scripts/orchestrator.mjs replay PRD-XXX <session-id>
```

Never claim completion without passing commands, changed files, criterion evidence, residual risks, and the current gate status.
