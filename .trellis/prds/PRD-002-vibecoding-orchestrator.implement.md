# Implementation plan: PRD-002 VibeCoding Orchestrator

## Phase 0 — Repository baseline and API research

- [ ] Inspect the installed Pi version, project-local package API, subagent dispatch API, and sandbox/tool permission behavior.
- [ ] Record findings in `.trellis/research/PRD-002-pi-runtime-baseline.md`.
- [ ] Create a minimal no-op orchestrator smoke fixture that can read `AGENTS.md` and a PRD without editing files.
- [ ] Confirm the selected extension/runtime boundary and its supported JSONL or RPC surface.

Rollback point: no existing workflow files are changed until the no-op smoke fixture passes.

## Phase 1 — State, events, and approvals

- [ ] Add versioned state/event schemas and deterministic reducer.
- [ ] Add event writer with sequence, atomic append, redaction, and artifact paths.
- [ ] Add state restore/replay and duplicate-event tests.
- [ ] Add approval controller for `prd_scope`, `risk`, `final_diff`, `merge`, and `deploy` gates.
- [ ] Add single-writer lock and stale-lock recovery policy.

Validation: unit tests for transitions, replay, gate expiry, concurrent reader/writer behavior, and redaction.

## Phase 2 — Registry and scheduler

- [ ] Add agent registry with role, tools, write permission, timeout, and output schema.
- [ ] Add tool registry adapters for repository, Git, mise tasks, worktrees, artifacts, and GitHub draft PR.
- [ ] Add dependency-aware scheduler for parallel read-only jobs.
- [ ] Add isolated worktree lifecycle for optional parallel writers.
- [ ] Add cancellation, timeout, retry, and blocked-state events.

Validation: deterministic scheduler fixtures with parallel explorer/test/security jobs and one writer lock.

## Phase 3 — Natural-language intake and phase skills

- [ ] Add project-local `/skill:vibecoding` or equivalent Pi entry prompt.
- [ ] Add intake classifier and context loader for root/module AGENTS, specs, profiles, PRDs, and baseline research.
- [ ] Add Spec proposal and PRD proposal artifact writers.
- [ ] Add phase prompts for specify, plan, implement, verify, debug, review, deliver, and archive.
- [ ] Ensure every prompt states scope policy, approval policy, evidence requirement, and no-auto-merge rule.

Validation: natural-language fixture produces a proposal and pauses at the scope approval gate.

## Phase 4 — Implementation, verify, and debug loop

- [ ] Route implementation commands through `mise run` task contract.
- [ ] Dispatch read-only explorer/test/security agents around the single implementer.
- [ ] Capture targeted/full verification output as artifacts.
- [ ] Add failure classifier, diagnostics fan-out, minimal-fix aggregation, and bounded retry loop.
- [ ] Require regression evidence before marking a failure solved.

Validation: fixture with intentional failing test reaches debugger, adds regression evidence, and passes verify within retry budget.

## Phase 5 — Delivery, resume, and archive

- [ ] Generate criterion-to-evidence completion report.
- [ ] Create Draft PR only after final diff gate.
- [ ] Persist PR URL and checks.
- [ ] Restore an interrupted session without duplicating commits, PRs, or tool calls.
- [ ] Archive merged PRD and run record while retaining audit artifacts.

Validation: interrupted end-to-end fixture resumes, completes, and produces one Draft PR/evidence set.

## Quality gates

Before requesting review:

```bash
mise run doctor
mise run setup
mise run verify
```

Additional checks:

- shellcheck and shfmt for shell adapters;
- schema validation for state/events/agent results;
- secret-pattern and forbidden-path tests;
- no destructive Git command scan;
- integration tests for no-profile and multi-profile fixtures;
- final diff and evidence table review.

## Risk controls

- Keep implementation behind an opt-in feature flag.
- Use a mock Pi/tool/subagent adapter for deterministic tests.
- Never allow a second writer on the primary worktree.
- Stop on ambiguous scope, missing approval, or repeated failure.
- Keep all generated artifacts under `.trellis/runs/` and ignore secrets/transient caches.
