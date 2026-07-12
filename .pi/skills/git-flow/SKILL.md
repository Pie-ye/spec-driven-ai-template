---
name: git-flow
description: Enforce one-PRD-per-branch Git policy and prepare reviewable changes.
---

# Branch policy

Start from updated `main`; use `prd/<id>-<slug>`, `fix/<id>-<slug>`, or `refactor/<id>-<slug>`. Use worktrees only for intentional parallel work.

# Commit policy

Use focused, traceable commits. Before review run `git status --short`, inspect the diff, fetch the base branch, and execute `./.trellis/scripts/verify.sh`.

# Rules

Do not merge or force-push automatically. Never include secrets. Report branch, base, changed files, policy violations, and recommendation.

