# PRD-002 Pi Runtime Baseline

Date: 2026-07-12

## Scope

This baseline records the local Pi runtime available while implementing the first VibeCoding orchestrator slice. It covers the project configuration, the installed delegation package, and the runtime boundary selected for the initial adapter.

## Findings

| Area | Finding | Consequence |
|---|---|---|
| Pi CLI | Pi `0.80.6` is available as `pi` on the implementation host. | The project can use Pi project resources and skill discovery when Pi is installed on the local machine. |
| Pi project resources | `.pi/settings.json` enables `./skills` and `./prompts`, and declares `pi-subagents@0.34.0`. | `vibecoding` is discoverable as a project-local skill; delegation is supplied by the pinned package declaration. |
| Pi process configuration | `.pi/sandbox.json` allows the project filesystem, `.trellis/runs`, and the orchestrator Node entry point. Credential paths are denied. | Orchestrator state and artifacts can stay within the clone and the declared sandbox. |
| Subagent dispatch | `pi-subagents@0.34.0` exposes the `subagent` tool, parallel/chain modes, async lifecycle artifacts, and an in-process versioned RPC event bus. | The next adapter can dispatch parallel read-only roles through the supported `subagents:rpc:v1:*` event contract. |
| RPC surface | Protocol version `1`; methods include `ping`, `status`, `spawn`, `interrupt`, and `stop`. Async spawn accepts an agent/task payload and does not open clarification UI. | The scheduler should treat Pi RPC as an optional runtime capability and persist its own lifecycle events independently. |
| Core runtime | `scripts/orchestrator.mjs` uses Node standard library only. | The template core does not gain a language Profile just to run the orchestrator. |

## Initial implementation boundary

Phase 1 implements a local durable state/event adapter, not the complete Pi RPC scheduler. It provides:

- versioned `state.json` and append-only `events.jsonl`;
- deterministic sequence validation through `replay`;
- approval gates for scope, risk, final diff, merge, and deployment;
- a single-writer lock;
- redacted tool artifacts;
- resume/state inspection commands;
- a project-local VibeCoding skill describing the Pi dispatch contract.

The scheduler, agent registry, Pi RPC adapter, and delivery integration remain later implementation phases. No existing Profile task contract is changed by this slice.

## Verification

```text
node --check scripts/orchestrator.mjs       PASS
node scripts/orchestrator.mjs self-test     PASS
git diff --check                            PASS
```

The self-test uses an isolated temporary run root and verifies approval pause/resume, writer lock acquire/release, secret redaction, phase transition, and event replay.
