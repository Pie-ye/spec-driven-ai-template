# Trellis Workflow

## Phases

1. **Plan** — clarify the request and write `prd.md`; complex work also gets `design.md` and `implement.md`.
2. **Execute** — implement only the active PRD on its branch.
3. **Finish** — verify, review, update reusable specs, commit, and open a PR.

## Guardrails

- Planning approval does not imply merge approval.
- One active PRD per branch.
- Read the applicable spec index before editing.
- Every acceptance criterion needs evidence or an explicit `UNCLEAR` status.
- Use a separate worktree only for an intentional parallel task or review.

## Suggested phase checklist

| Phase | Required output |
|---|---|
| Plan | `prd.md`, and for complex work `design.md` + `implement.md` |
| Execute | focused commits and changed tests |
| Finish | `verify.sh` output, review verdict, updated specs when needed |

