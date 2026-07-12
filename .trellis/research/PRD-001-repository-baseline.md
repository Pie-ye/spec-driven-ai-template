# PRD-001 repository baseline and gap analysis

## Baseline

The repository began as a 52-file Trellis + Pi template. It had a root `mise.toml` declaring Node 22, Python 3.12, Go 1.24, and pnpm 10. Verification was hard-coded for pnpm, Python pytest, and Go. Trellis records were under `.trellis/spec/` and `.trellis/tasks/`; there was no explicit profile manifest, module dispatcher, profile-local tool configuration, PRD branch helper, finish gate, PRD/Spec/ADR/Review/Retro canonical template set, or profile matrix CI entry point.

## Existing assets retained

- Root `AGENTS.md`, Pi settings/agents/skills, legacy `.trellis/spec/` and `.trellis/tasks/`.
- Existing Docker, bootstrap, remote tmux, and GitHub workflow examples.
- Existing `.trellis/scripts/verify.sh` as a compatibility wrapper.

## Gaps addressed

| Gap | New contract |
|---|---|
| Language assumptions | Root mise now contains only core task entry points and optional shell tooling. |
| No explicit capabilities | `.template/profiles.toml` and idempotent `enable-profile.sh`. |
| Fixed verification | `scripts/run-task.sh` dispatches profile/module adapters. |
| Mixed policy scopes | Root and profile/module `AGENTS.md` files plus Pi execution prompts. |
| Weak PRD gate | Canonical PRD evidence table, branch helper, finish helper, and review template. |
| CI drift | CI calls `mise run doctor`, `mise run setup`, and `mise run verify`. |

## Constraints

The execution host for this session does not have mise, shellcheck, or shfmt installed. Tests therefore validate manifest behavior, shell syntax, static policy, and no-profile verification locally; profile-native tool execution is covered by adapters and CI after a profile is explicitly enabled.
