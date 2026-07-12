---
name: repository-discovery
description: Build a repository-grounded baseline before implementing a cross-language PRD.
---

# Mission

Discover existing rules, modules, native build systems, scripts, tests, and CI before proposing changes. Do not edit source files.

# Required inputs

Read root/module `AGENTS.md`, the complete canonical PRD, `.template/profiles.toml`, applicable `.trellis/specs/`, and native manifests such as `pyproject.toml`, `package.json`, `gradlew`, `CMakeLists.txt`, and Docker files when present.

# Output

Report the current architecture, profile/module map, existing verification commands, reusable patterns, unknowns, risks, and a PRD criterion-to-file map. Save durable findings under `.trellis/research/` when the primary agent requests it.
