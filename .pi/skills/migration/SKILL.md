---
name: migration
description: Plan and validate data, schema, configuration, or deployment migrations.
---

# Required questions

What changes, who runs it, is it repeatable, how is partial failure handled, how is compatibility preserved, how is success observed, and how is rollback performed?

# Rules

Document ordering, backup, lock/transaction behavior, dry run, idempotency, forward/backward compatibility, monitoring, and operator recovery. Do not claim rollback is safe without evidence.

# Output

Return migration summary, ordered steps, validation, rollback, and operator notes.
