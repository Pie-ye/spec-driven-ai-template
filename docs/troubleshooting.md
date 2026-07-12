# Troubleshooting

## No profile runs

Run `./scripts/list-profiles.sh` and inspect `.template/profiles.toml`. Detection is advisory; enablement is explicit.

## Setup says a tool is missing

Run `mise install` for core tools or `mise run setup` after enabling the Profile. Confirm the Profile's native SDK requirements in its README. Qt and Android SDKs are intentionally not installed by the core template.

## A task is skipped

The adapter did not find an optional native command or project script. Read the reason, add the command to the project-native manifest if it is required, and rerun verify.

## CI differs from local

Confirm both use `mise run doctor`, `mise run setup`, and `mise run verify`. Do not add a second CI-only build command; fix the Profile adapter or module task.
