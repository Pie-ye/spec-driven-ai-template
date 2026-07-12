# Execute one PRD

Execute only the active canonical PRD under `.trellis/prds/`.

Before editing:

1. Read root `AGENTS.md`.
2. Read every affected module/profile `AGENTS.md`.
3. Read the complete PRD, relevant `.trellis/specs/`, research, and ADRs.
4. Confirm the current branch matches the PRD and inspect `git status`.
5. Run `mise run doctor` and inspect the current repository behavior.
6. Report intended files and acceptance-criterion mapping.

During implementation:

- Keep one primary writing agent and use read-only exploration/review agents.
- Use the profile task contract and native build system; do not invent a second command path.
- Add or update targeted tests.
- Keep changes inside the PRD scope. Record discoveries as follow-up PRDs.
- Do not hide failures, secrets, generated artifacts, or out-of-scope edits.

Before completion:

1. Run targeted checks and then `mise run setup` and `mise run verify`.
2. Inspect the final diff and branch.
3. Fill every evidence-table row in the PRD.
4. Report exact commands, results, risks, and unverified items.
5. Stop at independent review; do not merge `main`.
