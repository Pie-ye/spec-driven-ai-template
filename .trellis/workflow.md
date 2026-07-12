# Trellis Workflow

## Phases

1. **Plan** — clarify the request and write a canonical PRD under `.trellis/prds/`; complex work may add research and an ADR.
2. **Execute** — implement only the active PRD on its branch.
3. **Finish** — verify, review, update reusable specs, commit, and open a PR.

## Guardrails

- Planning approval does not imply merge approval.
- One active PRD per branch.
- Read the applicable `.trellis/specs/` documents before editing.
- Every acceptance criterion needs evidence or an explicit `UNCLEAR` status.
- Use a separate worktree only for an intentional parallel task or review.

## Suggested phase checklist

| Phase | Required output |
|---|---|
| Plan | canonical PRD, evidence table, and relevant research/ADR |
| Execute | focused commits and changed tests |
| Finish | `mise run verify` output, review verdict, updated specs when needed |
