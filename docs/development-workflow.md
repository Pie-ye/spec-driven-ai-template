# Development workflow

1. Write or update a Spec.
2. Create a prioritized PRD with non-goals and evidence rows.
3. Start one branch from updated `main`.
4. Read root/module rules and baseline the repository.
5. Plan, implement, and test only the active PRD.
6. Run the same `mise run doctor`, `mise run setup`, and `mise run verify` used by CI.
7. Have a separate reviewer map each criterion to evidence.
8. Open a PR; merge only after review, CI, and scope gates pass.
9. Record reusable lessons in specs, ADRs, or retrospectives.
