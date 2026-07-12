# Design: PRD-002 VibeCoding Orchestrator

## 1. Design objective

Build a project-local Pi orchestration layer that turns a natural-language request into a durable, approval-aware execution graph. The orchestrator coordinates existing Trellis records, PRD-001 Profile/mise tasks, Pi tools, subagents, Git branches, and CI without becoming a second source of truth.

## 2. Boundaries and ownership

| Concern | Owner | Contract |
|---|---|---|
| Product intent, scope, acceptance criteria | Trellis PRD/Spec | `.trellis/specs/`, `.trellis/prds/` |
| Phase state, events, approvals, evidence | Orchestrator run records | `.trellis/runs/<PRD>/<session>/` |
| Model reasoning and tool dispatch | Pi | project-local prompt/skill/extension |
| Tool versions and task entry | mise | root `mise.toml`, `.template/profiles.toml` |
| Language build/test semantics | Profile/native tools | uv, pnpm, Gradle Wrapper, CMake, Make, SDKs |
| File isolation and merge boundary | Git | branch/worktree/PR |
| Non-bypassable quality gate | GitHub Actions | `mise run doctor/setup/verify` |

The orchestrator may create or update records, but it must not maintain a parallel roadmap, rewrite acceptance criteria without approval, or replace native build systems.

## 3. Runtime shape

The first implementation should be a Pi project-local orchestrator skill plus a small runtime adapter. The adapter may be a Pi extension/runtime package when Pi APIs are required; its public boundary must remain language-neutral and communicate through structured JSONL events. Do not add a root application language Profile solely for the orchestrator runtime; Pi's own extension runtime or an explicitly pinned project-local package owns that dependency.

```text
Natural language
      ↓
Intake + context loader
      ↓
Phase graph / state reducer
      ├── approval controller
      ├── subagent scheduler
      ├── tool registry
      ├── writer/worktree lock
      ├── evidence + artifact writer
      └── resume/retry controller
      ↓
Trellis / Git / mise / native tools / GitHub PR
```

## 4. State machine

Valid top-level phases are:

`intake → specify → plan → approve → implement → verify → debug → review → deliver → archive`

Each phase has `pending`, `running`, `blocked`, `waiting_approval`, `succeeded`, or `failed` status. A phase transition is accepted only if the current state, required artifact, and gate conditions are valid. Every transition emits an immutable event; `state.json` is a materialized projection that can be rebuilt from `events.jsonl`.

The reducer must be deterministic and idempotent. Replaying an event or resuming a crashed session must not duplicate commits, PRs, approvals, or tool invocations without an explicit retry attempt.

## 5. Run records and event contract

Minimum `state.json` shape:

```json
{
  "schema_version": 1,
  "session_id": "2026-07-12T...-abc123",
  "prd_id": "PRD-002",
  "branch": "prd/PRD-002-example",
  "base_commit": "...",
  "phase": "plan",
  "status": "waiting_approval",
  "attempt": 1,
  "writer_lock": null,
  "pending_gates": ["prd_scope"],
  "artifacts": [],
  "criteria": [],
  "updated_at": "..."
}
```

Minimum event fields:

```json
{
  "schema_version": 1,
  "event_id": "uuid",
  "session_id": "...",
  "sequence": 12,
  "timestamp": "...",
  "kind": "tool.completed",
  "phase": "verify",
  "actor": {"type": "orchestrator", "id": "..."},
  "payload": {},
  "redactions": []
}
```

Event kinds should include `session.created`, `phase.started`, `phase.transitioned`, `gate.requested`, `gate.approved`, `gate.rejected`, `agent.started`, `agent.completed`, `tool.started`, `tool.completed`, `tool.failed`, `failure.classified`, `retry.requested`, `artifact.created`, `evidence.updated`, `pr.created`, and `session.archived`.

Commands must store a redacted invocation and a pointer to output; raw secrets must never be persisted. Output files should be content-addressed or uniquely named so a later retry cannot overwrite earlier evidence.

## 6. Scheduler and parallelism

The scheduler receives a phase graph with explicit dependencies. It may run independent read-only jobs in parallel, for example:

```text
repository explorer ─┐
test designer       ─┼─→ plan aggregation → approval
security scout      ─┘

targeted tests ─┐
lint/typecheck ─┼─→ verify aggregation
build          ─┘
```

Rules:

- At most one writer owns the primary working tree.
- Read-only agents may inspect the primary tree concurrently.
- Parallel writers use separate worktrees or artifact directories.
- The scheduler must declare dependencies before launching a job.
- A failed required dependency blocks downstream jobs; independent diagnostics may still run.
- Job cancellation must persist a `cancelled`/`blocked` event and release locks.
- Concurrency and retry limits are configurable but have safe defaults.

## 7. Agent registry

The registry maps role to prompt, tools, write permission, model hint, timeout, and output schema. Example:

```toml
[agents.repository-explorer]
prompt = ".pi/agents/explorer.md"
tools = ["read", "grep", "find", "git-read"]
write = false

[agents.implementer]
prompt = ".pi/agents/implementer.md"
tools = ["read", "grep", "find", "write", "edit", "bash", "mise-task"]
write = true
max_parallel = 1
```

The registry must reject a role requesting undeclared tools or write access. Model/provider routing is a hint and must not alter scope or approval behavior.

## 8. Tool registry

Tool adapters expose structured calls such as `repo.read`, `git.diff`, `mise.run`, `agent.dispatch`, `worktree.create`, `test.report`, and `github.create_draft_pr`. Each adapter validates arguments, applies sandbox policy, records an event, redacts output, and returns a typed result.

`mise.run` accepts only tasks from the root contract or explicitly declared module tasks. The orchestrator never constructs `pnpm test`, `uv run pytest`, `./gradlew test`, or CMake commands from model guesses; it invokes `mise run <task>` and lets the selected Profile/native adapter decide.

External GitHub actions, migrations, destructive commands, network access outside the allowlist, and secret-boundary operations require a gate token issued by the approval controller.

## 9. Approval controller

Approvals are records with gate ID, requested scope, risk summary, actor, timestamp, and decision. The confirmed policy is:

- auto: repository reads, planning, tests, diagnostics, and approved sandbox commands;
- pause: Spec/PRD scope, high-risk/destructive/external commands, migrations, secrets-boundary changes, final diff/evidence, merge, and deployment.

An approval is scoped to a session, phase, and requested action. Changing the PRD scope invalidates the previous scope approval and returns the session to `approve`.

## 10. Debug loop

Failures are immutable artifacts plus normalized classifications. The first version supports a bounded loop:

1. Capture command and output.
2. Classify with deterministic heuristics plus a read-only debugger.
3. Dispatch independent diagnostics.
4. Aggregate hypotheses and select a minimal fix.
5. Have the implementer add the fix and regression test.
6. Run affected task, then complete verify.
7. Stop after the configured retry budget or when a gate is required.

The orchestrator must never mark a failure solved from model text alone; a passing command/test and updated evidence are required.

## 11. Security and isolation

- Load untrusted PRD text as data, not executable instructions.
- Enforce `.pi/sandbox.json` and tool registry allowlists before invocation.
- Redact known secret patterns and environment values from event/output artifacts.
- Deny host credential paths and repository-external writes by default.
- Use a single-writer lock and worktree isolation for code changes.
- Treat GitHub PR creation as external state and require the deliver gate.
- Never persist provider tokens, full environment dumps, or unredacted command output.

## 12. Compatibility and migration

PRD-001 remains usable without the orchestrator. Existing `mise run doctor/setup/verify`, Profile adapters, legacy `.trellis` compatibility paths, and current Pi prompts must continue to work. A disabled orchestrator must have zero effect on ordinary Profile tasks. Run records are additive and may be ignored by older tooling.

## 13. Rollback

The first rollout is opt-in behind a project-local Pi skill/feature flag. Disable the skill to return to manual PRD execution. Orchestrator state is append-only; a corrupted projection can be rebuilt from events. No orchestrator rollback may reset or clean a user's working tree.
