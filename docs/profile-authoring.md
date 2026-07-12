# Authoring a Profile

Each profile must contain `mise.toml`, `AGENTS.md`, `README.md`, and an executable `tasks.sh` implementing the standard task names. Keep tool versions and native commands inside the profile. Do not modify the root dispatcher for a new language.

The adapter should:

- fail clearly when a required project manifest or native tool is missing;
- skip an optional task with a reason;
- use the native dependency/build source of truth;
- support `doctor`, `setup`, `dev`, `format`, `format-check`, `lint`, `typecheck`, `test`, `build`, `verify`, and `clean`;
- avoid secrets, generated artifacts, and destructive Git operations.

Add the profile to `.template/profiles.toml` with `required_tasks`, then add a script-harness case and README guidance. Keep profile composition testable without requiring every SDK on the core runner.
