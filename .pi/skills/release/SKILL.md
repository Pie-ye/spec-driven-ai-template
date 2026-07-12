---
name: release
description: Check release readiness without publishing artifacts automatically.
---

# Checklist

Verify PRD review, CI, version/changelog consistency, migration notes, compatibility, security findings, rollback instructions, and required approvals. Inspect `git diff` and tags as needed.

# Rules

Do not create tags, publish packages, or deploy without explicit authorization. Report unknowns as blockers when they affect release safety.

# Output

Return readiness, release-note draft, outstanding items, and `READY` or `BLOCKED`.

