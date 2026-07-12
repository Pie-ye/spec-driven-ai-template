# Pi project resources

Pi is the execution engine, not a second product planner. Load the canonical PRD and repository/module `AGENTS.md` files before editing. Trellis owns scope and lifecycle; Pi reports evidence and never merges `main` automatically.

- Prompts: `.pi/prompts/`
- Read-only or focused agents: `.pi/agents/`
- Reusable skills: `.pi/skills/`
- Package and sandbox declarations: `.pi/settings.json`, `.pi/sandbox.json`

## VibeCoding entry

The `vibecoding` skill is the natural-language entry point for PRD-driven work. It keeps the execution state and artifacts inside the current clone, pauses at scope/risk/final-diff gates, and uses `scripts/orchestrator.mjs` for durable state, event replay, approvals, and the single-writer lock.

The installed `pi-subagents` package provides the parallel delegation runtime. The skill may use its `scout`, `planner`, `worker`, and `reviewer` roles, while Trellis remains the source of truth for Specs, PRDs, and acceptance evidence.
