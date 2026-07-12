# PRD-001: Cross-Language Spec-Driven AI Development Framework

| Field | Value |
|---|---|
| ID | PRD-001 |
| Priority | P0 |
| Status | In Progress |
| Branch | `prd/PRD-001-cross-language-template-foundation` |
| Dependencies | None |
| Follow-up | PRD-002 Pi engine, PRD-003 Trellis lifecycle, PRD-004 CI profiles |

## Background

The template must support Web, Python, Kotlin/Android, Qt/C++, C, and polyglot monorepos without installing every language tool or replacing native build systems. Trellis owns product requirements and evidence; Pi executes one PRD; mise provides version and task entry points; native tools remain authoritative; Git and CI enforce review boundaries.

## Goals

- Provide explicit, composable `python`, `web`, `kotlin`, `qt-cpp`, and `c` profiles.
- Keep language-specific tools out of the root mise configuration.
- Expose `doctor`, `setup`, `dev`, `format`, `format-check`, `lint`, `typecheck`, `test`, `build`, `verify`, and `clean` through one task contract.
- Use `.template/profiles.toml` as the explicit capability manifest.
- Support module-local `AGENTS.md` and native build systems.
- Provide safe PRD branch/finish helpers, Pi prompts, review templates, and a CI entry point shared with local verification.

## Non-goals

No product application, production deployment platform, provider quota manager, cc-switch/OpenUsage integration, automatic merge, or complete Pi extension implementation is included.

## Design rules

1. One PRD maps to one branch.
2. Only one primary writing agent may modify a working tree at once.
3. mise manages tools and task entry; Gradle Wrapper, CMake, uv, pnpm, Docker, and platform SDKs remain authoritative.
4. File detection may suggest a profile in `doctor`, but never enables one.
5. Scripts must be idempotent and must not use force push, `git reset --hard`, `git clean -fdx`, or automatic branch deletion.

## Acceptance criteria

- [x] AC-001: Core template does not declare Node, Python, Java, Qt, GCC, or Clang in root `mise.toml`.
- [x] AC-002: Profiles can be enabled independently through an idempotent manifest command.
- [x] AC-003: Multiple enabled profiles/modules are aggregated and labeled by the root task runner.
- [x] AC-004: Trellis canonical paths define specs and PRDs; prompts prohibit scope expansion and record follow-ups.
- [x] AC-005: Pi prompts and scripts never merge `main` automatically.
- [x] AC-006: Local and CI verification use `mise run verify` as the primary entry point.
- [x] AC-007: Root and module `AGENTS.md` rules are documented and loaded by execution prompts.
- [x] AC-008: The PRD template, finish script, and review template require criterion-to-evidence mapping.
- [x] AC-009: Re-enabling a profile does not duplicate or overwrite configuration.
- [x] AC-010: Core scripts contain no destructive Git operations.
- [x] AC-011: README documents install, profile enablement, Spec, PRD, branch, Pi, verify, and PR creation.
- [x] AC-012: No cc-switch, OpenUsage, or provider quota workflow is a dependency.

## Definition of Done

- [x] Core manifest, task contract, scripts, profiles, templates, prompts, CI, PR policy, and docs exist.
- [x] Python, Web, Kotlin, Qt/C++, and C profile adapters are present.
- [x] Core shell tests cover no-profile, single-profile, multi-profile, idempotent enablement, invalid manifest, missing tools, and required task failures.
- [x] `mise run verify` is the documented local/CI gate.
- [ ] GitHub Actions on the PR branch has completed; this is filled after push.
- [ ] Independent reviewer verdict is `READY_TO_MERGE`.

## Evidence table

| AC | Status | Implementation | Evidence |
|---|---|---|---|
| AC-001 | Pass | `mise.toml`, profile configs | root tool scan; core verify |
| AC-002 | Pass | `.template/profiles.toml`, `scripts/enable-profile.sh` | idempotency test |
| AC-003 | Pass | `scripts/lib/profiles.sh`, `scripts/run-task.sh` | multi-profile harness |
| AC-004 | Pass | `.trellis/specs`, `.trellis/prds`, Pi prompts | prompt/spec inspection |
| AC-005 | Pass | `AGENTS.md`, branch/finish scripts, Pi prompts | static policy scan |
| AC-006 | Pass | `mise.toml`, `scripts/verify.sh`, CI workflow | task contract inspection |
| AC-007 | Pass | root/profile AGENTS and execute prompt | prompt inspection |
| AC-008 | Pass | PRD/review templates and finish script | evidence gate test |
| AC-009 | Pass | `scripts/enable-profile.sh` | repeat-enable test |
| AC-010 | Pass | core scripts | destructive-command scan |
| AC-011 | Pass | `README.md`, docs | documentation inspection |
| AC-012 | Pass | repository scan | no matching dependency/workflow |
