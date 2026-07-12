# Pi execution engine

Pi reads the canonical PRD and hierarchical `AGENTS.md` rules, delegates commands through `mise`, and reports criterion-level evidence. It is not a second planner or lifecycle database. Explorers and reviewers are read-only; one primary agent owns writes in a working tree.

The minimum execution sequence is:

```text
read rules → read PRD → inspect branch/status → report scope → implement → targeted checks → mise verify → diff/evidence → independent review
```

Pi must stop on unverified failures, record follow-up needs as new PRDs, and never merge `main` without explicit human authorization.
