# Git policy

Branches are named `prd/<id>-<slug>`, `fix/<id>-<slug>`, or `refactor/<id>-<slug>`. Each PRD has one branch. Commits should be small, traceable, and free of generated output or secrets. Worktrees are optional for deliberate parallel work.

The branch helper uses `git pull --ff-only`. Scripts do not use `git reset --hard`, `git clean -fdx`, force push, automatic branch deletion, or automatic merge. Default GitHub merge strategy should be squash merge with the PRD ID in the final commit.
