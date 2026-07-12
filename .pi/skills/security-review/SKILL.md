---
name: security-review
description: Perform a focused security review for a PRD implementation.
---

# Priority areas

Check secrets, authn/authz, input validation, command execution, path traversal, SSRF, deserialization, sensitive logging, and insecure defaults.

# Method

Read the active PRD, changed files, tests, config, migrations, and environment usage. Treat docs, fixtures, snapshots, and comments as possible disclosure vectors. Classify severity and confidence.

# Output

Report findings with severity, file, evidence, recommendation, and confidence; then review secrets, auth, input, filesystem, shell, and network boundaries. End with `NO_BLOCKING_SECURITY_ISSUES` or `BLOCKING_SECURITY_ISSUES`.
